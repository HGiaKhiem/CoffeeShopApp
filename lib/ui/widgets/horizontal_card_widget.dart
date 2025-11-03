import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_coffee_shop_app/ui/theme/app_theme.dart';
import 'package:flutter_coffee_shop_app/ui/widgets/custom_filledbutton.dart';
import '../../entities/coffee.dart';

class HorizontalCardWidget extends StatelessWidget {
  final Coffee coffee;
  final VoidCallback? onTap;

  const HorizontalCardWidget({
    Key? key,
    required this.coffee,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.only(left: 9, right: 15, top: 9, bottom: 9),
          height: 110,
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
          child: Row(
            children: [
              // Hình ảnh cà phê
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
                      child:
                          const Icon(Icons.broken_image, color: Colors.white54),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),

              // Thông tin
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên cà phê
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
                    // Giá tiền
                    Text(
                      "\$${coffee.gia}",
                      style: const TextStyle(
                        color: Colors.brown,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),

                    // Hàng icon + nút
                    Row(
                      children: [
                        const Icon(
                          Icons.coffee_rounded,
                          color: Apptheme.iconColor,
                          size: 20,
                        ),
                        const Spacer(),
                        CustomFilledButton(
                          onTap: () {},
                          height: 34,
                          width: 33,
                          color: Apptheme.buttonBackground1Color,
                          child: const Center(
                            child: Icon(
                              CupertinoIcons.paperplane_fill,
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
