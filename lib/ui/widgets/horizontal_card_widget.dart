import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_coffee_shop_app/entities/coffee.dart';
import 'package:flutter_coffee_shop_app/ui/screens/detail_screen.dart';
import 'package:flutter_coffee_shop_app/ui/theme/app_theme.dart';

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

  // Format VNĐ
  String formatCurrency(num value) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailScreen(
                coffee: coffee,
                idBan: idBan,
                idKhachHang: idKhachHang,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(10),
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
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  coffee.hinhanh,
                  width: 140,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 140,
                    color: Colors.grey.shade800,
                    child: const Icon(Icons.broken_image,
                        color: Colors.white54, size: 28),
                  ),
                ),
              ),
              const SizedBox(width: 15),

              // Nội dung
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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

                    // Giá
                    Text(
                      formatCurrency(coffee.gia),
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const Spacer(),

                    // Icon nhỏ (để đẹp)
                    Row(
                      children: const [
                        Icon(Icons.coffee_rounded,
                            color: Apptheme.iconColor, size: 18),
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
