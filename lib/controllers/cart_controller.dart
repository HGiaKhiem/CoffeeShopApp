import 'package:flutter_coffee_shop_app/controllers/auth_controller.dart';
import 'package:flutter_coffee_shop_app/entities/entities_library.dart';

class CartController {
  static final Map<String, List<CartItem>> _userCarts = {};

  static List<CartItem> get items {
    final uid = AuthController.currentUser?.id ?? 'guest';
    return List.unmodifiable(_userCarts[uid] ?? []);
  }

  static void addToCart(CartItem item) {
    final uid = AuthController.currentUser?.id ?? 'guest';
    _userCarts.putIfAbsent(uid, () => []);
    _userCarts[uid]!.add(item);
  }

  static void clearCart() {
    final uid = AuthController.currentUser?.id ?? 'guest';
    _userCarts[uid]?.clear();
  }
}
