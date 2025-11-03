import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_coffee_shop_app/entities/coffee.dart';
import 'package:flutter_coffee_shop_app/ui/screens/detail_screen.dart';
import 'package:flutter_coffee_shop_app/ui/theme/app_theme.dart';
import 'package:flutter_coffee_shop_app/ui/widgets/custom_filledbutton.dart';

class VerticalCardWidget extends StatelessWidget {
  final Coffee coffee;
  final VoidCallback? onAddToCart;

  const VerticalCardWidget({
    Key? key,
    required this.coffee,
    this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            colors: [
              Color(0xff282C34),
              Color(0xff10131A),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh + rating
            Stack(
              alignment: Alignment.topRight,
              children: [
                SizedBox(
                  height: 145,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      coffee.hinhanh, // lấy từ Supabase
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade800,
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.white54,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
                // Rating blur box
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      alignment: Alignment.center,
                      width: 50,
                      height: 25,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                      ),
                      // child: Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //   children: [
                      //     const Icon(
                      //       Icons.star,
                      //       color: Apptheme.reviewIconColor,
                      //       size: 15,
                      //     ),
                      //     Text(
                      //       coffee..toStringAsFixed(1),
                      //       style: Apptheme.reviewRatting,
                      //     ),
                      //   ],
                      // ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Tên cà phê (dẫn tới trang chi tiết)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(coffee: coffee),
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

            // Subtitle (có thể thay bằng coffee.description nếu có)
            Text(
              coffee.mota?.isNotEmpty == true ? coffee.mota! : "With Oat Milk",
              style: Apptheme.cardSubtitleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),

            // Giá + nút thêm
            Row(
              children: [
                Row(
                  children: [
                    Text('\$', style: Apptheme.priceCurrencySmall),
                    const SizedBox(width: 3),
                    Text(
                      coffee.gia.toString(),
                      style: Apptheme.priceValueSmall,
                    ),
                  ],
                ),
                const Spacer(),
                CustomFilledButton(
                  onTap: onAddToCart ?? () {},
                  height: 31,
                  width: 34,
                  color: Apptheme.buttonBackground1Color,
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
