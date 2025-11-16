import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_coffee_shop_app/controllers/cart_controller.dart';
import 'package:flutter_coffee_shop_app/ui/screens/qr_scan_screen.dart';

String formatMoney(double value) {
  return value
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ".");
}

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

      /// Nếu đã áp dụng trước đó
      if (cart.appliedVoucher != null) {
        _selectedVoucherId = cart.appliedVoucher!["id_khv"];
      }
    });
  }

  Future<void> _handleDatMon() async {
    final cart = context.read<CartController>();

    final error = await cart.datMon(widget.idBan);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error ?? "🍽 Đặt món thành công!",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: error == null ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _handleThanhToan() async {
    final cart = context.read<CartController>();

    final error = await cart.thanhToan(widget.idBan);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error ?? "💵 Thanh toán thành công!",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: error == null ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4E342E),
        centerTitle: true,
        title: const Text("Giỏ hàng ☕"),
      ),
      body: cart.items.isEmpty
          ? const Center(
              child: Text(
                "🛒 Giỏ hàng trống",
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    itemBuilder: (context, i) {
                      final item = cart.items[i];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2B2B2B),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Ảnh
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

                            /// Nội dung món
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// Tên món
                                  Text(
                                    item.mon.tenmon,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  /// Size
                                  Text(
                                    "Size: ${item.tuyChon['size']}",
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 13),
                                  ),

                                  /// Topping
                                  if (item.tuyChon['toppings'] != null &&
                                      (item.tuyChon['toppings'] as List)
                                          .isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        "Topping: ${(item.tuyChon['toppings'] as List).join(', ')}",
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13),
                                      ),
                                    ),

                                  /// Note
                                  if (item.tuyChon['note'] != null &&
                                      item.tuyChon['note']
                                          .toString()
                                          .trim()
                                          .isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        "Ghi chú: ${item.tuyChon['note']}",
                                        style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 13,
                                            fontStyle: FontStyle.italic),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            /// Nút tăng giảm
                            Column(
                              children: [
                                IconButton(
                                  onPressed: () => cart.updateQuantity(
                                      item, item.soLuong - 1),
                                  icon: const Icon(Icons.remove_circle_outline,
                                      color: Colors.white70),
                                ),
                                Text(
                                  "${item.soLuong}",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                                IconButton(
                                  onPressed: () => cart.updateQuantity(
                                      item, item.soLuong + 1),
                                  icon: const Icon(Icons.add_circle_outline,
                                      color: Colors.white70),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),

                /// Footer tổng tiền + voucher + nút
                _buildFooter(cart),
              ],
            ),
    );
  }

  Widget _buildFooter(CartController cart) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
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
                  final id = v["id_khv"];
                  final data = v["voucher"];

                  return DropdownMenuItem(
                    value: id,
                    child: Text(
                      "${data['ten_voucher']} - ${data['phantram_giam']}%",
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                })
              ],
              onChanged: (value) {
                setState(() => _selectedVoucherId = value);

                if (value == -1) {
                  cart.removeVoucher();
                  return;
                }

                final v = _vouchers.firstWhere((e) => e["id_khv"] == value);
                cart.applyVoucher({
                  'id_khv': v['id_khv'],
                  'phantram_giam': v['voucher']['phantram_giam'],
                  'ten_voucher': v['voucher']['ten_voucher'],
                });
              },
            ),

          const SizedBox(height: 12),

          /// Tổng tiền
          Text(
            "Tổng: ${formatMoney(cart.tongTien)}đ",
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),

          /// Giảm giá
          if (cart.appliedVoucher != null)
            Text(
              "-${cart.appliedVoucher!['phantram_giam']}% (${cart.appliedVoucher!['ten_voucher']})",
              style: const TextStyle(color: Colors.greenAccent, fontSize: 14),
            ),

          /// Tiền thanh toán
          Text(
            "Thanh toán: ${formatMoney(cart.tongTienSauGiam)}đ",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          /// Button: Đặt món - Thanh toán
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _handleDatMon,
                  icon: const Icon(Icons.fastfood),
                  label: const Text("Đặt món"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _handleThanhToan,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text("Thanh toán"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                  ),
                ),
              )
            ],
          ),

          const SizedBox(height: 10),

          /// Nút quay lại QR
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QrScanScreen()),
              );
            },
            icon: const Icon(Icons.qr_code_2),
            label: const Text("Quét QR"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown.shade600,
            ),
          )
        ],
      ),
    );
  }
}
