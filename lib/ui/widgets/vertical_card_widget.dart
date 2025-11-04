import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_coffee_shop_app/entities/coffee.dart';
import 'package:flutter_coffee_shop_app/entities/cart_item.dart';
import 'package:flutter_coffee_shop_app/controllers/cart_controller.dart';
import 'package:flutter_coffee_shop_app/ui/screens/detail_screen.dart';
import 'package:flutter_coffee_shop_app/ui/theme/app_theme.dart';
import 'package:flutter_coffee_shop_app/ui/widgets/custom_filledbutton.dart';

class VerticalCardWidget extends StatelessWidget {
  final Coffee coffee;
  final int? idBan;
  final int? idKhachHang;

  const VerticalCardWidget({
    Key? key,
    required this.coffee,
    this.idBan,
    this.idKhachHang,
  }) : super(key: key);

  ///  Định dạng giá theo kiểu Việt Nam
  String formatCurrency(num value) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final cartController = CartController(); // Singleton

    return Padding(
      padding: const EdgeInsets.only(right: 22),
      child: Container(
        padding: const EdgeInsets.all(9),
        width: 150,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(23)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xff282C34), Color(0xff10131A)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh món
            SizedBox(
              height: 145,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  coffee.hinhanh,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade800,
                    child: const Icon(Icons.broken_image,
                        color: Colors.white54, size: 30),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Tên món
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(
                      coffee: coffee,
                      idBan: idBan,
                      idKhachHang: idKhachHang,
                    ),
                  ),
                );
              },
              child: Text(
                coffee.tenmon,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Apptheme.cardTitleSmall,
              ),
            ),
            const SizedBox(height: 3),

            // Mô tả
            Text(
              coffee.mota?.isNotEmpty == true ? coffee.mota! : "Ngon lắm nhé!",
              style: Apptheme.cardSubtitleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),

            // Giá + nút thêm
            Row(
              children: [
                //  Giá VNĐ
                Text(
                  formatCurrency(coffee.gia),
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                ),
                const Spacer(),

                // Nút thêm vào giỏ
                CustomFilledButton(
                  onTap: () {
                    final item = CartItem(
                      mon: coffee,
                      soLuong: 1,
                      giaBan: coffee.gia,
                      tuyChon: {
                        'size': 'M',
                        'topping': [],
                        'ghichu': '',
                        'idBan': idBan,
                        'idKhachHang': idKhachHang,
                      },
                    );
                    cartController.addToCart(item);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Đã thêm ${coffee.tenmon} vào giỏ hàng',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.brown.shade700,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  height: 31,
                  width: 34,
                  color: Apptheme.buttonBackground1Color,
                  child: const Icon(Icons.add, color: Colors.white, size: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
