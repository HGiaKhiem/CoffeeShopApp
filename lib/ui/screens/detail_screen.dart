import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_coffee_shop_app/entities/entities_library.dart';
import 'package:flutter_coffee_shop_app/ui/screens/home_screen.dart';
import 'package:flutter_coffee_shop_app/ui/theme/app_theme.dart';
import 'package:flutter_coffee_shop_app/ui/widgets/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_coffee_shop_app/controllers/home_controller.dart';

class DetailScreen extends StatefulWidget {
  final Coffee coffee;
  const DetailScreen({
    Key? key,
    required this.coffee,
  }) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  List<Size> _sizes = [];
  Size? _selectedSize;
  double _totalPrice = 0;

  @override
  void initState() {
    super.initState();
    _loadSizes();
    _totalPrice = widget.coffee.gia;
  }

  Future<void> _loadSizes() async {
    final sizes = await HomeController.getAllSizes();
    setState(() {
      _sizes = sizes;
    });
  }

  void _onSizeSelected(Size size) {
    setState(() {
      _selectedSize = size;
      _totalPrice = widget.coffee.gia + size.giatang;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Apptheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section -> Card Image
              Expanded(
                child: CardImageView(coffee: widget.coffee),
              ),
              const SizedBox(height: 30),

              // Section -> Description
              Text('Description', style: Apptheme.descriptionTitle),
              const SizedBox(height: 15),
              DescriptionView(
                  description: widget.coffee.mota ?? 'Không có mô tả'),
              const SizedBox(height: 30),

              // 🟤 Section -> Size chọn
              Text('Select Size', style: Apptheme.subtileLarge),
              const SizedBox(height: 15),
              _sizes.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _sizes.map((size) {
                        final bool isSelected =
                            _selectedSize?.id_size == size.id_size;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: CustomFilledButton(
                              onTap: () => _onSizeSelected(size),
                              width: 91,
                              height: 36,
                              color: isSelected
                                  ? Apptheme.buttonBackground1Color
                                  : Apptheme.buttonBackground2Color,
                              borderColor: isSelected
                                  ? Apptheme.accentColor
                                  : Apptheme.buttonBorderColor,
                              child: Text(
                                '${size.tensize}',
                                style: isSelected
                                    ? Apptheme.buttonActiveTextStyle
                                    : Apptheme.buttonInactiveTextStyle,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
              const SizedBox(height: 30),

              // 🟤 Section -> Price & Buy button
              SizedBox(
                height: 56,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text('Price', style: Apptheme.priceTitleLarge),
                        const Spacer(),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '\$ ',
                                style: Apptheme.priceCurrencyLarge,
                              ),
                              TextSpan(
                                text: _totalPrice.toStringAsFixed(2),
                                style: Apptheme.priceValueLarge,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    CustomFilledButton(
                      onTap: () {},
                      width: 188,
                      height: 56,
                      borderRadius: 16,
                      color: Apptheme.buttonBackground1Color,
                      child: Text('Buy Now', style: Apptheme.buttonTextStyle),
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

// 🧱 Các widget phụ vẫn giữ nguyên
class CardImageView extends StatelessWidget {
  final Coffee coffee;
  const CardImageView({Key? key, required this.coffee}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.network(
              coffee.hinhanh ?? 'https://i.imgur.com/NoImage.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error),
            ),
          ),
        ),
        Positioned(
          top: 20,
          left: 20,
          child: CustomIconButton(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
            width: 38,
            height: 38,
            borderRadius: 10,
            child: const Icon(CupertinoIcons.back, color: Apptheme.iconColor),
          ),
        ),
        Positioned(
          top: 20,
          right: 20,
          child: CustomIconButton(
            onTap: () {},
            width: 38,
            height: 38,
            borderRadius: 10,
            child: const Icon(Icons.favorite, color: Apptheme.iconColor),
          ),
        ),
        BlurCardView(coffee: coffee),
      ],
    );
  }
}

class BlurCardView extends StatelessWidget {
  final Coffee coffee;
  const BlurCardView({
    super.key,
    required this.coffee,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 4,
          sigmaY: 4,
        ),
        child: Container(
          alignment: Alignment.center,
          height: 152,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coffee.tenmon,
                          style: Apptheme.cardTitleLarge,
                        ),
                        Text(
                          '', // Không có ingredients, để trống
                          style: Apptheme.cardSubtitleLarge,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      width: 57,
                      height: 57,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Apptheme.cardChipBackgroundColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 2,
                          bottom: 5,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/coffe.svg',
                              height: 25,
                            ),
                            Text(
                              'Coffee',
                              style: Apptheme.cardChipTextStyle,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 57,
                      height: 57,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Apptheme.cardChipBackgroundColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 2,
                          bottom: 5,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SvgPicture.asset('assets/icons/milk.svg'),
                            Text(
                              'Milk',
                              style: Apptheme.cardChipTextStyle,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Apptheme.reviewIconColor,
                      size: 20,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '0.0', // Không có rating
                      style: Apptheme.cardTitleSmall,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '(0)', // Không có reviews
                      style: Apptheme.cardSubtitleSmall,
                    ),
                    const Spacer(),
                    Container(
                      width: 103,
                      height: 31,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        color: Apptheme.cardChipBackgroundColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 2,
                          bottom: 5,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              'Medium Roasted',
                              style: Apptheme.cardChipTextStyle,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SizeChoiseView extends StatelessWidget {
  const SizeChoiseView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomFilledButton(
          onTap: () {},
          width: 91,
          height: 36,
          color: Apptheme.buttonBackground2Color,
          borderColor: Apptheme.buttonBorderColor,
          child: Text(
            'S',
            style: Apptheme.buttonActiveTextStyle,
          ),
        ),
        CustomFilledButton(
          onTap: () {},
          width: 91,
          height: 36,
          color: Apptheme.buttonBackground2Color,
          child: Text(
            'M',
            style: Apptheme.buttonInactiveTextStyle,
          ),
        ),
        CustomFilledButton(
          onTap: () {},
          width: 91,
          height: 36,
          color: Apptheme.buttonBackground2Color,
          child: Text(
            'L',
            style: Apptheme.buttonInactiveTextStyle,
          ),
        ),
      ],
    );
  }
}

class DescriptionView extends StatelessWidget {
  final String description;
  const DescriptionView({
    super.key,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: description.substring(
                0, description.length > 120 ? 120 : description.length),
            style: Apptheme.descriptionContent,
          ),
          if (description.length > 120) ...[
            TextSpan(
              text: ' ...',
              style: Apptheme.descriptionReadMore,
            ),
            TextSpan(
              text: ' Read More',
              style: Apptheme.descriptionReadMore,
            ),
          ],
        ],
      ),
    );
  }
}
