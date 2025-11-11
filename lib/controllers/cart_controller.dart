import 'package:flutter/material.dart';
import 'package:flutter_coffee_shop_app/entities/cart_item.dart';

class CartController extends ChangeNotifier {
  final List<CartItem> _items = [];
  Map<String, dynamic>? _appliedVoucher; // lưu thông tin voucher đang dùng

  List<CartItem> get items => List.unmodifiable(_items);
  Map<String, dynamic>? get appliedVoucher => _appliedVoucher;

  /// Tổng tiền gốc
  double get tongTien =>
      _items.fold(0, (sum, item) => sum + (item.giaBan * item.soLuong));

  /// Tổng sau khi áp dụng giảm giá
  double get tongTienSauGiam {
    if (_appliedVoucher == null) return tongTien;
    final giam = _appliedVoucher!['phantram_giam'] ?? 0;
    return tongTien * (1 - giam / 100);
  }

  /// Áp dụng voucher
  void applyVoucher(Map<String, dynamic> voucher) {
    _appliedVoucher = voucher;
    notifyListeners();
  }

  /// Gỡ voucher
  void removeVoucher() {
    _appliedVoucher = null;
    notifyListeners();
  }

  void addToCart(CartItem item) {
    final index = _items.indexWhere((e) =>
        e.mon.id_mon == item.mon.id_mon &&
        e.tuyChon.toString() == item.tuyChon.toString());
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
}
