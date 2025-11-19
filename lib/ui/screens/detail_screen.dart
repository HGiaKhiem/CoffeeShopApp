// 🔥 DETAIL SCREEN FULL VERSION HOÀN CHỈNH 🔥

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:flutter_coffee_shop_app/ui/theme/app_theme.dart';
import 'package:flutter_coffee_shop_app/ui/widgets/widgets.dart';
import 'package:flutter_coffee_shop_app/entities/cart_item.dart';
import 'package:flutter_coffee_shop_app/entities/entities_library.dart';
import 'package:flutter_coffee_shop_app/controllers/home_controller.dart';
import 'package:flutter_coffee_shop_app/controllers/cart_controller.dart';

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
  // SIZE
  List<Size> _sizes = [];
  Size? _selectedSize;

  // TOPPING
  List<ToppingModel> _toppings = [];
  List<ToppingModel> _selectedToppings = [];

  // NOTE
  String _note = "";

  // PRICE
  double _totalPrice = 0;

  // REVIEWS
  late Future<List<Map<String, dynamic>>> _futureReviews;

  @override
  void initState() {
    super.initState();
    _loadSizes();
    _loadToppings();
    _futureReviews = HomeController.getRecentReviews(widget.coffee.id_mon);
    _totalPrice = widget.coffee.gia;
  }

  // LOAD SIZE
  Future<void> _loadSizes() async {
    final sizes = await HomeController.getAllSizes();
    setState(() => _sizes = sizes);
  }

  // LOAD TOPPING
  Future<void> _loadToppings() async {
    final data = await HomeController.getAllToppings();
    setState(() => _toppings = data);
  }

  // SELECT SIZE
  void _onSizeSelected(Size size) {
    setState(() {
      _selectedSize = size;
      _recalculateTotal();
    });
  }

  // SELECT TOPPING
  void _toggleTopping(ToppingModel topping) {
    setState(() {
      if (_selectedToppings.contains(topping)) {
        _selectedToppings.remove(topping);
      } else {
        _selectedToppings.add(topping);
      }
      _recalculateTotal();
    });
  }

  // RECALCULATE TOTAL
  void _recalculateTotal() {
    double base = widget.coffee.gia;
    double sizeCost = _selectedSize?.giatang ?? 0;
    double toppingCost = _selectedToppings.fold(0, (sum, t) => sum + t.giatang);

    setState(() {
      _totalPrice = base + sizeCost + toppingCost;
    });
  }

  String formatMoney(double value) {
    final f =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    return f.format(value);
  }

  void _addToCart() {
    final cart = Provider.of<CartController>(context, listen: false);

    final item = CartItem(
      mon: widget.coffee,
      soLuong: 1,
      giaBan: _totalPrice,
      tuyChon: {
        "size": _selectedSize?.tensize ?? "M",
        "toppings": _selectedToppings.map((t) => t.tentopping).toList(),
        "ghichu": _note,
        "idBan": widget.idBan ?? 1,
        "idKhachHang": widget.idKhachHang ?? 4,
      },
    );

    cart.addToCart(item);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Đã thêm ${widget.coffee.tenmon} vào giỏ hàng!",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.brown,
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
              // IMAGE
              CardImageView(coffee: widget.coffee),
              const SizedBox(height: 25),

              // DESCRIPTION
              Text("Mô tả", style: Apptheme.descriptionTitle),
              const SizedBox(height: 10),
              DescriptionExpandable(
                  text: widget.coffee.mota ?? "Không có mô tả"),
              const SizedBox(height: 28),

              // SIZE
              Text("Chọn size", style: Apptheme.subtileLarge),
              const SizedBox(height: 10),
              _sizes.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _sizes.map((size) {
                        bool selected = _selectedSize?.id_size == size.id_size;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: CustomFilledButton(
                              onTap: () => _onSizeSelected(size),
                              width: 90,
                              height: 36,
                              color: selected
                                  ? Apptheme.buttonBackground1Color
                                  : Apptheme.buttonBackground2Color,
                              borderColor: selected
                                  ? Apptheme.accentColor
                                  : Apptheme.buttonBorderColor,
                              child: Text(
                                "${size.tensize} (+${formatMoney(size.giatang)})",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      selected ? Colors.white : Colors.white70,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

              const SizedBox(height: 28),

              // TOPPING
              Text("Chọn topping", style: Apptheme.subtileLarge),
              const SizedBox(height: 10),
              _toppings.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _toppings.map((t) {
                        bool selected = _selectedToppings.contains(t);
                        return GestureDetector(
                          onTap: () => _toggleTopping(t),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? Colors.brown.shade600
                                  : Colors.white.withOpacity(.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    selected ? Colors.orange : Colors.white24,
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  t.tentopping,
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : Colors.white70,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "+${formatMoney(t.giatang)}",
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.amber
                                        : Colors.white54,
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

              const SizedBox(height: 28),

              // NOTE
              Text("Ghi chú cho món", style: Apptheme.subtileLarge),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: TextField(
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (t) => _note = t,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Ghi chú thêm cho món...",
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // PRICE + ADD BUTTON
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Giá",
                          style:
                              TextStyle(color: Colors.white70, fontSize: 16)),
                      const SizedBox(height: 5),
                      Text(
                        formatMoney(_totalPrice),
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
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
                    child: Text("Thêm vào giỏ hàng",
                        style: Apptheme.buttonTextStyle),
                  ),
                ],
              ),

              const SizedBox(height: 35),

              // REVIEWS
              const Text(
                "Đánh giá gần đây",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              FutureBuilder(
                future: _futureReviews,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.brown),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("☕ Chưa có đánh giá nào",
                        style: TextStyle(color: Colors.white70));
                  }

                  final reviews = snapshot.data!;
                  return Column(
                    children: reviews.map((r) {
                      return ReviewCard(review: r);
                    }).toList(),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

//
// REVIEW CARD
//
class ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final user = review["khachhang"];
    final sosao = review["sosao"] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Image.network(
              user?["AvatarURL"] ??
                  "https://rubeafovywlrgxblfmlr.supabase.co/storage/v1/object/public/avatar/avatar.png",
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),

          // TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?["tenkh"] ?? "Khách ẩn danh",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),

                // Stars
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < sosao ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    ),
                  ),
                ),

                if ((review["nhanxet"] ?? "").isNotEmpty)
                  Text(
                    review["nhanxet"],
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),

                Text(
                  (review["ngaydanhgia"] ?? "").toString().substring(0, 10),
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

//
// DESCRIPTION EXPANDABLE
//
class DescriptionExpandable extends StatefulWidget {
  final String text;

  const DescriptionExpandable({super.key, required this.text});

  @override
  State<DescriptionExpandable> createState() => _DescriptionExpandableState();
}

class _DescriptionExpandableState extends State<DescriptionExpandable> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final showMore = widget.text.length > 120;

    final displayText = expanded
        ? widget.text
        : widget.text.substring(0, showMore ? 120 : widget.text.length);

    return GestureDetector(
      onTap: () => setState(() => expanded = !expanded),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(text: displayText, style: Apptheme.descriptionContent),
            if (showMore)
              TextSpan(
                text: expanded ? "  Thu gọn" : "  ... Xem thêm",
                style: Apptheme.descriptionReadMore,
              )
          ],
        ),
      ),
    );
  }
}

//
// IMAGE VIEW
//
class CardImageView extends StatelessWidget {
  final Coffee coffee;

  const CardImageView({super.key, required this.coffee});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Image.network(
            coffee.hinhanh ?? "https://i.imgur.com/NoImage.png",
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
            child: const Icon(
              CupertinoIcons.back,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
