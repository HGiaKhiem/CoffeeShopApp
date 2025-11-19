import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_coffee_shop_app/controllers/cart_controller.dart';
import 'package:flutter_coffee_shop_app/ui/screens/order_detail_screen.dart';

String formatMoney(double v) => v
    .toStringAsFixed(0)
    .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ".");

class CartScreen extends StatefulWidget {
  final int idBan;
  const CartScreen({super.key, required this.idBan});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> _vouchers = [];
  bool _loadingVoucher = true;
  int? _selectedVoucherId;

  @override
  void initState() {
    super.initState();
    _loadVoucher();
  }

  Future<void> _loadVoucher() async {
    final cart = context.read<CartController>();

    setState(() => _loadingVoucher = true);

    final data = await cart.loadVouchers();

    setState(() {
      _vouchers = data;
      _loadingVoucher = false;

      if (cart.appliedVoucher != null) {
        _selectedVoucherId = cart.appliedVoucher!["id_khv"];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.brown.shade700,
        centerTitle: true,
        title: const Text("Giỏ hàng ☕"),
      ),
      body: cart.items.isEmpty
          ? const Center(
              child: Text("🛒 Giỏ hàng trống",
                  style: TextStyle(color: Colors.white70, fontSize: 18)),
            )
          : Column(
              children: [
                Expanded(child: _buildCartList(cart)),
                _buildFooter(cart),
              ],
            ),
    );
  }

  // =============================
  //      LIST MÓN TRONG GIỎ
  // =============================
  Widget _buildCartList(CartController cart) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cart.items.length,
      itemBuilder: (_, i) {
        final item = cart.items[i];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF2B2B2B),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  item.mon.hinhanh,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),

              /// Nội dung
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.mon.tenmon,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    Text("Size: ${item.tuyChon['size']}",
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                    if ((item.tuyChon['toppings'] as List).isNotEmpty)
                      Text(
                        "Topping: ${(item.tuyChon['toppings'] as List).join(', ')}",
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                    if (item.tuyChon['note'] != null &&
                        item.tuyChon['note'].toString().trim().isNotEmpty)
                      Text("Ghi chú: ${item.tuyChon['note']}",
                          style: const TextStyle(
                              color: Colors.white54,
                              fontStyle: FontStyle.italic,
                              fontSize: 13)),
                  ],
                ),
              ),

              /// Nút +/- số lượng
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: Colors.white70),
                    onPressed: () =>
                        cart.updateQuantity(item, item.soLuong - 1),
                  ),
                  Text("${item.soLuong}",
                      style:
                          const TextStyle(color: Colors.white, fontSize: 16)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        color: Colors.white70),
                    onPressed: () =>
                        cart.updateQuantity(item, item.soLuong + 1),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  // =============================
  //        FOOTER (TỔNG + VOUCHER + ĐẶT MÓN)
  // =============================
  Widget _buildFooter(CartController cart) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF2B2B2B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          /// Voucher
          if (_loadingVoucher)
            const CircularProgressIndicator(color: Colors.brown)
          else if (_vouchers.isNotEmpty)
            DropdownButtonFormField<int>(
              value: _selectedVoucherId,
              dropdownColor: const Color(0xFF3E3E3E),
              decoration: InputDecoration(
                labelText: "Chọn voucher",
                labelStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: [
                const DropdownMenuItem(
                  value: -1,
                  child: Text("Không dùng voucher",
                      style: TextStyle(
                          color: Colors.white70, fontStyle: FontStyle.italic)),
                ),
                ..._vouchers.map((v) {
                  final vc = v["voucher"];
                  return DropdownMenuItem(
                    value: v["id_khv"],
                    child: Text(
                      "${vc['ten_voucher']} - ${vc['phantram_giam']}%",
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() => _selectedVoucherId = value);

                if (value == -1) {
                  cart.removeVoucher();
                  return;
                }

                final v = _vouchers.firstWhere((e) => e["id_khv"] == value);

                cart.applyVoucher({
                  "id_khv": v["id_khv"],
                  "ten_voucher": v["voucher"]["ten_voucher"],
                  "phantram_giam": v["voucher"]["phantram_giam"],
                });
              },
            ),

          const SizedBox(height: 12),

          Text("Tổng: ${formatMoney(cart.tongTien)}đ",
              style: const TextStyle(color: Colors.white70, fontSize: 16)),

          if (cart.appliedVoucher != null)
            Text(
              "-${cart.appliedVoucher!['phantram_giam']}% (${cart.appliedVoucher!['ten_voucher']})",
              style: const TextStyle(color: Colors.greenAccent, fontSize: 14),
            ),

          Text(
            "Thanh toán: ${formatMoney(cart.tongTienSauGiam)}đ",
            style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          /// Nút đặt món
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.fastfood),
              label: const Text("Đặt món", style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () async {
                final String? error = await cart.datMon(widget.idBan);

                if (!mounted) return;

                if (error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderDetailScreen(idBan: widget.idBan),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
