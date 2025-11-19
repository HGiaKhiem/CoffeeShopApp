// lib/ui/screens/payment_qr_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class PaymentQRScreen extends StatefulWidget {
  final int idBan;
  final int idKhach;
  final double tongTien;

  const PaymentQRScreen({
    super.key,
    required this.idBan,
    required this.idKhach,
    required this.tongTien,
  });

  @override
  State<PaymentQRScreen> createState() => _PaymentQRScreenState();
}

class _PaymentQRScreenState extends State<PaymentQRScreen> {
  final supabase = Supabase.instance.client;

  // 🔥 Tài khoản ngân hàng
  final String bankId = "VCB";
  final String accountNumber = "103032294";
  final String accountName = "LUONG QUOC HUY";

  bool _loading = false;

  // ============================
  //   CẬP NHẬT TRẠNG THÁI ĐƠN
  // ============================
  Future<void> _xacNhanThanhToan() async {
    if (_loading) return;

    setState(() => _loading = true);

    try {
      // Lấy tất cả đơn CHƯA THANH TOÁN của khách tại bàn
      final don = await supabase
          .from("donhang")
          .select("id_donhang")
          .eq("id_ban", widget.idBan)
          .eq("id_khachhang", widget.idKhach)
          .eq("trangthai", "CHUA_THANH_TOAN");

      final List listDon = don;

      // Thanh toán toàn bộ đơn
      for (var d in listDon) {
        await supabase.from("donhang").update(
            {"trangthai": "DA_THANH_TOAN"}).eq("id_donhang", d["id_donhang"]);
      }

      // Update trạng thái bàn: Trống
      await supabase
          .from("ban")
          .update({"trangthai": "Trống"}).eq("id_ban", widget.idBan);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("✅ Thanh toán thành công!"),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(milliseconds: 800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Lỗi thanh toán: $e"),
          backgroundColor: Colors.red.shade500,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String maThanhToan =
        "BAN${widget.idBan}_KH${widget.idKhach}_${DateTime.now().millisecondsSinceEpoch}";

    final String qrUrl =
        "https://img.vietqr.io/image/$bankId-$accountNumber-compact2.jpg"
        "?amount=${widget.tongTien.toStringAsFixed(0)}"
        "&addInfo=$maThanhToan"
        "&accountName=${Uri.encodeComponent(accountName)}";

    final moneyFormat =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF6EFEA),
      appBar: AppBar(
        backgroundColor: Colors.brown.shade700,
        title: const Text("QR Thanh toán"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // QR CODE
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  qrUrl,
                  width: 280,
                  height: 320,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                "Số tiền cần thanh toán",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                moneyFormat.format(widget.tongTien),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 28),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("💡 Thông tin chuyển khoản:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text("Ngân hàng: $bankId"),
                    Text("Số tài khoản: $accountNumber"),
                    Text("Chủ tài khoản: $accountName"),
                    Text("Nội dung: $maThanhToan"),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // NÚT XÁC NHẬN
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _xacNhanThanhToan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 6,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          "Xác nhận đã thanh toán",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
