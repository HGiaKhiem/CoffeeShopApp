import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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
  late Future<List<Map<String, dynamic>>> _futureReviews;

  @override
  void initState() {
    super.initState();
    _loadSizes();
    _totalPrice = widget.coffee.gia;
    _futureReviews = HomeController.getRecentReviews(widget.coffee.id_mon);
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

  String formatMoney(double value) {
    final formatCurrency = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return formatCurrency.format(value);
  }

  /// 🟢 Thêm vào giỏ hàng
  void _addToCart() {
    final cart = Provider.of<CartController>(context, listen: false);

    final int idBan = widget.idBan ?? 1;
    final int idKhach = widget.idKhachHang ?? 4;

    final item = CartItem(
      mon: widget.coffee,
      soLuong: 1,
      giaBan: _totalPrice,
      tuyChon: {
        'size': _selectedSize?.tensize ?? 'Mặc định',
        'idBan': idBan,
        'idKhachHang': idKhach,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ảnh
              CardImageView(coffee: widget.coffee),
              const SizedBox(height: 25),

              // Mô tả
              Text('Mô tả', style: Apptheme.descriptionTitle),
              const SizedBox(height: 10),
              DescriptionView(
                description: widget.coffee.mota ?? 'Không có mô tả',
              ),
              const SizedBox(height: 25),

              // Size + Giá
              Text('Chọn size', style: Apptheme.subtileLarge),
              const SizedBox(height: 10),
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

              const SizedBox(height: 25),

              // Giá + Thêm vào giỏ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Giá',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(
                        formatMoney(_totalPrice),
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                  CustomFilledButton(
                    onTap: _addToCart,
                    width: 180,
                    height: 56,
                    borderRadius: 16,
                    color: Apptheme.buttonBackground1Color,
                    child: Text('Thêm vào giỏ hàng',
                        style: Apptheme.buttonTextStyle),
                  ),
                ],
              ),

              const SizedBox(height: 35),

              // 🔸 Đánh giá gần đây (load 1 lần duy nhất)
              const Text(
                'Đánh giá gần đây',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _futureReviews,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(color: Colors.brown),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '☕ Chưa có đánh giá nào cho món này',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  final reviews = snapshot.data!;
                  return Column(
                    children: reviews.map((r) {
                      final user = r['khachhang'];
                      final sosao = r['sosao'] ?? 0;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Image.network(
                                user?['AvatarURL'] ??
                                    'https://rubeafovywlrgxblfmlr.supabase.co/storage/v1/object/public/avatar/avatar.png',
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?['tenkh'] ?? 'Khách ẩn danh',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Row(
                                    children: List.generate(5, (i) {
                                      return Icon(
                                        i < sosao
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 16,
                                      );
                                    }),
                                  ),
                                  if ((r['nhanxet'] ?? '').isNotEmpty)
                                    Text(
                                      r['nhanxet'],
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 13),
                                    ),
                                  Text(
                                    (r['ngaydanhgia'] ?? '')
                                        .toString()
                                        .substring(0, 10),
                                    style: const TextStyle(
                                        color: Colors.white54, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//
// 🧱 Widget phụ
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
          child: Image.network(
            coffee.hinhanh ?? 'https://i.imgur.com/NoImage.png',
            width: double.infinity,
            height: 260,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 20,
          left: 20,
          child: CustomIconButton(
            onTap: () => Navigator.pop(context),
            width: 38,
            height: 38,
            borderRadius: 10,
            child: const Icon(CupertinoIcons.back, color: Apptheme.iconColor),
          ),
        ),
      ],
    );
  }
}

class DescriptionView extends StatelessWidget {
  final String description;
  const DescriptionView({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    final showMore = description.length > 120;
    final shortText = description.substring(
      0,
      showMore ? 120 : description.length,
    );
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: shortText, style: Apptheme.descriptionContent),
          if (showMore)
            TextSpan(
              text: ' ... Xem thêm',
              style: Apptheme.descriptionReadMore,
            ),
        ],
      ),
    );
  }
}
