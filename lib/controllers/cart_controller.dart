import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../entities/cart_item.dart';

class CartController extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  final List<CartItem> _items = [];
  Map<String, dynamic>? _appliedVoucher;

  // ============================
  //   GETTERS
  // ============================
  List<CartItem> get items => List.unmodifiable(_items);
  Map<String, dynamic>? get appliedVoucher => _appliedVoucher;

  double get tongTien =>
      _items.fold(0, (sum, item) => sum + item.giaBan * item.soLuong);

  double get tongTienSauGiam {
    if (_appliedVoucher == null) return tongTien;
    final g = (_appliedVoucher!['phantram_giam'] ?? 0) as num;
    return tongTien * (1 - g / 100);
  }

  // ============================
  //   LẤY ID KHÁCH HÀNG
  // ============================
  Future<int> getIdKhachHangFromUid() async {
    try {
      final uid = _supabase.auth.currentUser?.id;
      if (uid == null) return 4;

      final data = await _supabase
          .from("khachhang")
          .select("id_khachhang")
          .eq("UID", uid)
          .maybeSingle();

      return (data?['id_khachhang'] as num?)?.toInt() ?? 4;
    } catch (_) {
      return 4;
    }
  }

  // ============================
  //      GIỎ HÀNG
  // ============================
  void addToCart(CartItem item) {
    final idx = _items.indexWhere(
      (e) =>
          e.mon.id_mon == item.mon.id_mon &&
          jsonEncode(e.tuyChon) == jsonEncode(item.tuyChon),
    );

    if (idx != -1) {
      _items[idx].soLuong += item.soLuong;
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void updateQuantity(CartItem item, int newQty) {
    if (newQty <= 0) {
      _items.remove(item);
    } else {
      final idx = _items.indexOf(item);
      if (idx != -1) _items[idx].soLuong = newQty;
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

  // ============================
  //   TẠO ĐƠN HÀNG MỚI
  // ============================
  Future<int> createNewDonHang(int idBan) async {
    final idKhach = await getIdKhachHangFromUid();

    final inserted = await _supabase
        .from("donhang")
        .insert({
          "id_ban": idBan,
          "id_khachhang": idKhach,
          "trangthai": "CHUA_THANH_TOAN",
          "thoigian": DateTime.now().toIso8601String(),
          "loaidon": "TAI_QUAN",
        })
        .select("id_donhang")
        .single();

    return (inserted["id_donhang"] as num).toInt();
  }

  // ============================
  //     ĐẶT MÓN – LUÔN TẠO ĐƠN MỚI
  // ============================
  Future<String?> datMon(int idBan) async {
    if (_items.isEmpty) return "Giỏ hàng trống";

    try {
      final idDon = await createNewDonHang(idBan);

      final rows = _items.map((item) {
        final tc = item.tuyChon;
        return {
          "id_donhang": idDon,
          "id_mon": item.mon.id_mon,
          "soluong": item.soLuong,
          "giaban": item.giaBan,
          "tuychon_json": {
            "size": tc["size"],
            "toppings": tc["toppings"] ?? [],
            "ghichu": tc["ghichu"] ?? "",
          },
        };
      }).toList();

      await _supabase.from("chitietdonhang").insert(rows);

      final double thanhToan = tongTienSauGiam;

      await _supabase
          .from("donhang")
          .update({"tongtien": thanhToan}).eq("id_donhang", idDon);

      /// bàn có khách
      await _supabase
          .from("ban")
          .update({"trangthai": "Có khách"}).eq("id_ban", idBan);

      //  ĐÁNH DẤU VOUCHER ĐÃ SỬ DỤNG
      if (_appliedVoucher != null) {
        final idKHV = _appliedVoucher!["id_khv"];

        await _supabase
            .from("khachhang_voucher")
            .update({"trangthai": "DA_SU_DUNG"}).eq("id_khv", idKHV);

        print("🔥 Voucher $idKHV => DA_SU_DUNG");
      }

      /// xoá giỏ + voucher sau khi đặt món
      clearCart();

      return null;
    } catch (e) {
      return "Lỗi đặt món: $e";
    }
  }

  // ============================
  //   VOUCHER
  // ============================
  Future<List<Map<String, dynamic>>> loadVouchers() async {
    try {
      final idKhach = await getIdKhachHangFromUid();

      final data = await _supabase.from("khachhang_voucher").select('''
          id_khv,
          id_voucher,
          trangthai,
          voucher(ten_voucher, phantram_giam, diem_doi, ngayhethan)
        ''').eq("id_khachhang", idKhach).eq("trangthai", "CHUA_SU_DUNG");

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      return [];
    }
  }

  void applyVoucher(Map<String, dynamic> voucher) {
    _appliedVoucher = voucher;
    notifyListeners();
  }

  void removeVoucher() {
    _appliedVoucher = null;
    notifyListeners();
  }
}
