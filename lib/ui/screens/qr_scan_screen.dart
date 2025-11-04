import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({Key? key}) : super(key: key);

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  bool _isScanned = false; // ✅ chặn quét liên tục
  String? _lastValue;

  void _handleDetect(String value) {
    // Nếu trùng hoặc đang xử lý => bỏ qua
    if (_isScanned || value == _lastValue) return;

    setState(() {
      _isScanned = true;
      _lastValue = value;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Đã quét mã: $value'),
        backgroundColor: Colors.brown.shade700,
        duration: const Duration(seconds: 2),
      ),
    );

    // Sau 2s có thể quét lại (nếu cần)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isScanned = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.brown.shade700,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Quay lại',
          ),
        ),
        title: const Text(
          "Quét mã QR để thanh toán",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),

      body: Stack(
        children: [
          /// Camera scan
          MobileScanner(
            fit: BoxFit.cover,
            onDetect: (capture) {
              for (final barcode in capture.barcodes) {
                final value = barcode.rawValue ?? '';
                if (value.isNotEmpty) _handleDetect(value);
              }
            },
          ),

          /// ✅ Khung quét (cao hơn, bo tròn đẹp)
          Align(
            alignment: const Alignment(0, -0.05),
            child: Container(
              width: 300,
              height: 320, // 👉 khung cao hơn
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.9),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),

          /// 🔆 Hướng dẫn + icon
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.qr_code_2, color: Colors.white70, size: 34),
                  SizedBox(height: 8),
                  Text(
                    "Đưa mã QR vào khung quét",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
