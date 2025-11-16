import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_coffee_shop_app/entities/coffee.dart';
import 'package:flutter_coffee_shop_app/ui/screens/detail_screen.dart';
import 'package:flutter_coffee_shop_app/ui/theme/app_theme.dart';

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

  /// Format tiền VNĐ
  String formatCurrency(num value) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 22),
      child: GestureDetector(
        onTap: () {
          // → Điều hướng vào chi tiết món
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
              // Ảnh
              SizedBox(
                height: 145,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    coffee.hinhanh,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade800,
                      child: const Icon(Icons.broken_image,
                          color: Colors.white54, size: 30),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Tên món
              Text(
                coffee.tenmon,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Apptheme.cardTitleSmall,
              ),
              const SizedBox(height: 3),

              // Mô tả
              Text(
                coffee.mota?.isNotEmpty == true
                    ? coffee.mota!
                    : "Ngon lắm nhé!",
                style: Apptheme.cardSubtitleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const Spacer(),

              // Giá
              Text(
                formatCurrency(coffee.gia),
                style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
