import 'package:flutter_coffee_shop_app/entities/coffee.dart';
import 'package:flutter_coffee_shop_app/entities/size.dart';
import 'package:flutter_coffee_shop_app/entities/topping.dart';

///  CartItem – một món trong giỏ hàng
class CartItem {
  final Coffee coffee;
  final Size? size;
  //final List<ToppingModel> toppings; // Danh sách topping
  int quantity; // Số lượng

  CartItem({
    required this.coffee,
    this.size,
    //  this.toppings = const [],
    this.quantity = 1,
  });

  /// topping
  // double get toppingTotal =>
  //     toppings.fold(0, (sum, t) => sum + t.giatang);

  /// cộng size + topping
  // double get unitPrice =>
  //     coffee.gia + (size?.giatang ?? 0) + toppingTotal;
}
