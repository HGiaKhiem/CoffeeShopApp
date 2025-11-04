import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_coffee_shop_app/entities/coffee.dart';
import 'package:flutter_coffee_shop_app/entities/cart_item.dart';
import 'package:flutter_coffee_shop_app/controllers/cart_controller.dart';
import 'package:flutter_coffee_shop_app/ui/screens/detail_screen.dart';
import 'package:flutter_coffee_shop_app/ui/theme/app_theme.dart';
import 'package:flutter_coffee_shop_app/ui/widgets/custom_filledbutton.dart';

class HorizontalCardWidget extends StatelessWidget {
  final Coffee coffee;
  final int? idBan;
  final int? idKhachHang;

  const HorizontalCardWidget({
    Key? key,
    required this.coffee,
    this.idBan,
    this.idKhachHang,
  }) : super(key: key);

  ///  Hàm format giá theo chuẩn Việt Nam
  String formatCurrency(num value) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final cartController = CartController();

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: GestureDetector(
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
        child: Container(
          padding: const EdgeInsets.only(left: 9, right: 15, top: 9, bottom: 9),
          height: 110,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(23)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xff282C34), Color(0xff10131A)],
            ),
          ),
          child: Row(
            children: [
              // Ảnh
              SizedBox(
                width: 140,
                height: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    coffee.hinhanh,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade800,
                      child: const Icon(Icons.broken_image, color: Colors.white54),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),

              // Nội dung
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên món
                    Text(
                      coffee.tenmon,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Apptheme.cardTitleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),

                    //  Giá (VNĐ)
                    Text(
                      formatCurrency(coffee.gia),
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),

                    // Nút thêm nhanh
                    Row(
                      children: [
                        const Icon(
                          Icons.coffee_rounded,
                          color: Apptheme.iconColor,
                          size: 20,
                        ),
                        const Spacer(),
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
                          height: 34,
                          width: 33,
                          color: Apptheme.buttonBackground1Color,
                          child: const Center(
                            child: Icon(
                              CupertinoIcons.cart_badge_plus,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
