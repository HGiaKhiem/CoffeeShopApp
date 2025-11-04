import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import 'package:flutter_coffee_shop_app/entities/entities_library.dart';
import 'package:flutter_coffee_shop_app/ui/screens/home_screen.dart';
import 'package:flutter_coffee_shop_app/ui/theme/app_theme.dart';
import 'package:flutter_coffee_shop_app/ui/widgets/widgets.dart';
import 'package:flutter_coffee_shop_app/controllers/home_controller.dart';
import 'package:flutter_coffee_shop_app/controllers/cart_controller.dart';
import 'package:flutter_coffee_shop_app/entities/cart_item.dart';

class DetailScreen extends StatefulWidget {
  final Coffee coffee;
  final int? idBan;
  final int? idKhachHang;

  const DetailScreen({
    Key? key,
    required this.coffee,
    this.idBan,
    this.idKhachHang,
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

  /// 🟢 Thêm vào giỏ hàng
  void _addToCart() {
    final cart = Provider.of<CartController>(context, listen: false);

    final item = CartItem(
      mon: widget.coffee,
      soLuong: 1,
      giaBan: _totalPrice,
      tuyChon: {
        'size': _selectedSize?.tensize ?? 'Mặc định',
        'idBan': widget.idBan,
        'idKhachHang': widget.idKhachHang,
      },
    );

    cart.addToCart(item);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '☕ Đã thêm ${widget.coffee.tenmon} vào giỏ hàng!',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.brown.shade700,
      ),
    );
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
                description: widget.coffee.mota ?? 'Không có mô tả',
              ),
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
                                size.tensize,
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

              // 🟤 Section -> Price & Add-to-cart
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
                      onTap: _addToCart,
                      width: 188,
                      height: 56,
                      borderRadius: 16,
                      color: Apptheme.buttonBackground1Color,
                      child: Text('Thêm vào giỏ hàng',
                          style: Apptheme.buttonTextStyle),
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

//
// 🧱 Các widget phụ giữ nguyên + tối ưu nhẹ
//

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
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            ),
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
  const BlurCardView({super.key, required this.coffee});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          alignment: Alignment.center,
          height: 152,
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.6)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(coffee.tenmon, style: Apptheme.cardTitleLarge),
                        Text('', style: Apptheme.cardSubtitleLarge),
                      ],
                    ),
                    const Spacer(),
                    _buildChip('assets/icons/coffe.svg', 'Coffee'),
                    const SizedBox(width: 10),
                    _buildChip('assets/icons/milk.svg', 'Milk'),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.star,
                        color: Apptheme.reviewIconColor, size: 20),
                    const SizedBox(width: 3),
                    Text('0.0', style: Apptheme.cardTitleSmall),
                    const SizedBox(width: 3),
                    Text('(0)', style: Apptheme.cardSubtitleSmall),
                    const Spacer(),
                    Container(
                      width: 103,
                      height: 31,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        color: Apptheme.cardChipBackgroundColor,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Medium Roasted',
                        style: Apptheme.cardChipTextStyle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String icon, String label) {
    return Container(
      width: 57,
      height: 57,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Apptheme.cardChipBackgroundColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(icon, height: 25),
          Text(label, style: Apptheme.cardChipTextStyle),
        ],
      ),
    );
  }
}

class DescriptionView extends StatelessWidget {
  final String description;
  const DescriptionView({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    final showMore = description.length > 120;
    final shortText = description.substring(0, showMore ? 120 : description.length);
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: shortText, style: Apptheme.descriptionContent),
          if (showMore)
            TextSpan(
              text: ' ... Read More',
              style: Apptheme.descriptionReadMore,
            ),
        ],
      ),
    );
  }
}
