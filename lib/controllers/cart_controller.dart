import 'package:flutter/material.dart';
import 'package:flutter_coffee_shop_app/entities/cart_item.dart';

class CartController extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  /// Tổng tiền tất cả món trong giỏ
  double get tongTien {
    return _items.fold(0, (sum, item) => sum + (item.giaBan * item.soLuong));
  }

  /// Thêm món mới vào giỏ
  void addToCart(CartItem item) {
    // Kiểm tra nếu món đã tồn tại (cùng id_mon & cùng tuychon)
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

  /// Cập nhật số lượng món
  void updateQuantity(CartItem item, int newQuantity) {
    if (newQuantity <= 0) {
      _items.remove(item);
    } else {
      final index = _items.indexOf(item);
      if (index != -1) {
        _items[index].soLuong = newQuantity;
      }
    }
    notifyListeners();
  }

  /// Xóa 1 món
  void removeItem(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  /// Xóa toàn bộ giỏ
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
