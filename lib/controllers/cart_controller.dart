import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../entities/cart_item.dart';

class CartController extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  final List<CartItem> _items = [];
  Map<String, dynamic>? _appliedVoucher;

  List<CartItem> get items => List.unmodifiable(_items);
  Map<String, dynamic>? get appliedVoucher => _appliedVoucher;

  double get tongTien =>
      _items.fold(0, (sum, item) => sum + (item.giaBan * item.soLuong));

  double get tongTienSauGiam {
    if (_appliedVoucher == null) return tongTien;
    final giam = _appliedVoucher!['phantram_giam'] ?? 0;
    return tongTien * (1 - giam / 100);
  }

  Future<int> getIdKhachHangFromUid() async {
    try {
      final uid = _supabase.auth.currentUser?.id;
      if (uid == null) return 4;

      final data = await _supabase
          .from('khachhang')
          .select('id_khachhang')
          .eq('UID', uid)
          .maybeSingle();

      if (data == null) return 4;
      return (data['id_khachhang'] as num).toInt();
    } catch (_) {
      return 4;
    }
  }

  //        GIỎ HÀNG
  void addToCart(CartItem item) {
    final index = _items.indexWhere((e) =>
        e.mon.id_mon == item.mon.id_mon &&
        jsonEncode(e.tuyChon) == jsonEncode(item.tuyChon));

    if (index != -1) {
      _items[index].soLuong += item.soLuong;
    } else {
      _items.add(item);
    }

    notifyListeners();
  }

  void updateQuantity(CartItem item, int newQuantity) {
    if (newQuantity <= 0) {
      _items.remove(item);
    } else {
      final index = _items.indexOf(item);
      if (index != -1) _items[index].soLuong = newQuantity;
    }
    notifyListeners();
  }

  void removeItem(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _appliedVoucher = null;
    notifyListeners();
  }

  // =============================
  //   TẠO HOẶC LẤY ĐƠN HÀNG
  Future<int> getOrCreateDonHang(int idBan) async {
    final existing = await _supabase
        .from('donhang')
        .select('id_donhang')
        .eq('id_ban', idBan)
        .eq('trangthai', 'CHUA_THANH_TOAN')
        .maybeSingle();

    if (existing != null) {
      return (existing['id_donhang'] as num).toInt();
    }

    final idKhach = await getIdKhachHangFromUid();

    final inserted = await _supabase
        .from('donhang')
        .insert({
          'id_ban': idBan,
          'id_khachhang': idKhach,
          'trangthai': 'CHUA_THANH_TOAN',
          'thoigian': DateTime.now().toIso8601String(),
        })
        .select('id_donhang')
        .single();

    return (inserted['id_donhang'] as num).toInt();
  }

  // =============================
  //         ĐẶT MÓN
  Future<String?> datMon(int idBan) async {
    if (_items.isEmpty) return "Giỏ hàng trống";

    try {
      final idDon = await getOrCreateDonHang(idBan);

      await _supabase.from('chitietdonhang').delete().eq('id_donhang', idDon);

      final rows = _items.map((item) {
        final tc = item.tuyChon;

        final tuyChonClean = {
          'size': tc['size'],
          'toppings': tc['toppings'],
          'note': tc['note'],
        };

        return {
          'id_donhang': idDon,
          'id_mon': item.mon.id_mon,
          'soluong': item.soLuong,
          'giaban': item.giaBan,
          'tuychon_json': tuyChonClean,
        };
      }).toList();

      await _supabase.from('chitietdonhang').insert(rows);

      await _supabase
          .from('donhang')
          .update({'tongtien': tongTien}).eq('id_donhang', idDon);

      await _supabase
          .from('ban')
          .update({'trangthai': 'Có khách'}).eq('id_ban', idBan);

      return null;
    } catch (e) {
      return "Lỗi đặt món: $e";
    }
  }

  // =============================
  //        THANH TOÁN
  Future<String?> thanhToan(int idBan) async {
    try {
      final existing = await _supabase
          .from('donhang')
          .select('id_donhang')
          .eq('id_ban', idBan)
          .eq('trangthai', 'CHUA_THANH_TOAN')
          .maybeSingle();

      if (existing == null) return "Không có đơn hàng để thanh toán";

      final idDon = (existing['id_donhang'] as num).toInt();

      await _supabase.from('donhang').update({
        'trangthai': 'DA_THANH_TOAN',
        'tongtien': tongTienSauGiam,
      }).eq('id_donhang', idDon);

      if (_appliedVoucher != null) {
        await _supabase.from('khachhang_voucher').update({
          'trangthai': 'DA_SU_DUNG',
          'ngay_sudung': DateTime.now().toIso8601String(),
        }).eq('id_khv', _appliedVoucher!['id_khv']);
      }

      await _supabase
          .from('ban')
          .update({'trangthai': 'Trống'}).eq('id_ban', idBan);

      clearCart();

      return null;
    } catch (e) {
      return "Lỗi thanh toán: $e";
    }
  }

  // =============================
  //        VOUCHER
  /// Load các voucher mà khách đang sở hữu và chưa sử dụng
  Future<List<Map<String, dynamic>>> loadVouchers() async {
    try {
      final idKhach = await getIdKhachHangFromUid();

      final data = await _supabase.from('khachhang_voucher').select('''
            id_khv,
            id_voucher,
            trangthai,
            voucher(ten_voucher, phantram_giam, diem_doi, ngayhethan)
          ''').eq('id_khachhang', idKhach).eq('trangthai', 'CHUA_SU_DUNG');

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      return [];
    }
  }

  /// Áp dụng voucher vào đơn hàng
  void applyVoucher(Map<String, dynamic> voucher) {
    _appliedVoucher = voucher;
    notifyListeners();
  }

  /// Gỡ voucher khỏi đơn hàng
  void removeVoucher() {
    _appliedVoucher = null;
    notifyListeners();
  }
}
