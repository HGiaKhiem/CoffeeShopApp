// lib/ui/screens/order_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'payment_qr_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final int idBan;

  const OrderDetailScreen({super.key, required this.idBan});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;
  int? _idKhach;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    /// 1) Lấy id_khach từ UID
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }

    final kh = await supabase
        .from("khachhang")
        .select("id_khachhang")
        .eq("UID", uid)
        .maybeSingle();

    _idKhach = (kh?["id_khachhang"] as num?)?.toInt();

    if (_idKhach == null) {
      setState(() => _loading = false);
      return;
    }

    /// 2) Load tất cả đơn chưa thanh toán
    final data = await supabase
        .from("donhang")
        .select("""
          id_donhang,
          id_ban,
          tongtien,
          trangthai,
          chitietdonhang(
            soluong,
            giaban,
            tuychon_json,
            mon(tenmon)
          )
        """)
        .eq("id_ban", widget.idBan)
        .eq("id_khachhang", _idKhach!)
        .eq("trangthai", "CHUA_THANH_TOAN");

    setState(() {
      _orders = List<Map<String, dynamic>>.from(data);
      _loading = false;
    });
  }

  // ==============================
  // UI
  // ==============================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.brown.shade700,
        title: const Text("Hóa đơn của bạn"),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : _orders.isEmpty
              ? const Center(
                  child: Text(
                    "Bạn chưa có đơn nào chưa thanh toán.",
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: _orders.map(_buildOrderCard).toList(),
                      ),
                    ),
                    _buildFooter(),
                  ],
                ),
    );
  }

  // ==============================
  // CARD HIỂN THỊ 1 ĐƠN
  // ==============================
  Widget _buildOrderCard(Map<String, dynamic> o) {
    final int idDon = o["id_donhang"];
    final List details = o["chitietdonhang"];

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B2B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// --- Title đơn hàng ---
          Text(
            "Đơn #$idDon",
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          /// --- DANH SÁCH CHI TIẾT ---
          ...details.map((ct) {
            final tenMon = ct['mon']?['tenmon'] ?? "Không rõ món";

            final tc = ct['tuychon_json'] ?? {};

            final size = tc['size'];
            final toppings = tc['toppings'];
            final note = tc['ghichu'];

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Tên món + số lượng
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tenMon,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "x${ct['soluong']}",
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  /// Size
                  if (size != null)
                    Text("• Size: $size",
                        style: const TextStyle(color: Colors.white70)),

                  /// Topping
                  if (toppings is List && toppings.isNotEmpty)
                    Text("• Topping: ${toppings.join(', ')}",
                        style: const TextStyle(color: Colors.white70)),

                  /// Ghi chú
                  if (note != null && note.toString().trim().isNotEmpty)
                    Text("• Ghi chú: $note",
                        style: const TextStyle(
                            color: Colors.white54,
                            fontStyle: FontStyle.italic)),

                  const SizedBox(height: 6),

                  /// Giá từng món
                  Text(
                    "Giá: ${ct['giaban']}đ",
                    style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }).toList(),

          /// Tổng đơn
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "Tổng: ${o['tongtien']}đ",
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }

  // ==============================
  // FOOTER: Tổng tất cả đơn
  // ==============================
  Widget _buildFooter() {
    final tong = _orders.fold<double>(
        0, (sum, o) => sum + (o["tongtien"] as num).toDouble());

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF2B2B2B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Text(
            "Tổng cần thanh toán: ${tong.toStringAsFixed(0)}đ",
            style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.qr_code),
              label: const Text("Thanh toán"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentQRScreen(
                      idBan: widget.idBan,
                      idKhach: _idKhach!,
                      tongTien: tong,
                    ),
                  ),
                );

                if (result == true) {
                  _loadData();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
