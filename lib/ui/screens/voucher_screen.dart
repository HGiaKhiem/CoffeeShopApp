import 'package:flutter/material.dart';
import 'package:flutter_coffee_shop_app/controllers/voucher_controller.dart';

class VoucherScreen extends StatefulWidget {
  final int idKhach;

  const VoucherScreen({super.key, required this.idKhach});

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {
  bool _loading = true;

  int _diem = 0;
  List<Map<String, dynamic>> _voucherShop = [];
  List<Map<String, dynamic>> _voucherDaDoi = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);

    _diem = await VoucherController.getDiemTichLuy(widget.idKhach);
    _voucherShop = await VoucherController.getVoucherList();
    _voucherDaDoi = await VoucherController.getVoucherDaDoi(widget.idKhach);

    setState(() => _loading = false);
  }

  Future<void> _doiVoucher(int idVoucher) async {
    final msg = await VoucherController.doiVoucher(widget.idKhach, idVoucher);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );

    _loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("🎁 Đổi Voucher"),
        backgroundColor: Colors.brown.shade700,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.brown))
          : Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    children: [
                      _buildSectionTitle("Voucher hiện có trong shop"),
                      ..._voucherShop.map(_buildShopVoucher),
                      const SizedBox(height: 18),
                      _buildSectionTitle("Voucher bạn đã đổi"),
                      ..._voucherDaDoi.map(_buildVoucherDaDoi),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // ====== UI Components ======

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.brown.shade600,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          const Text("Điểm tích lũy hiện tại",
              style: TextStyle(color: Colors.white70, fontSize: 15)),
          const SizedBox(height: 4),
          Text("$_diem điểm",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: Text(title,
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildShopVoucher(Map<String, dynamic> v) {
    final canRedeem = _diem >= v['diem_doi'];

    return Card(
      color: const Color(0xFF262626),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          v['ten_voucher'] ?? '',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Giảm: ${v['phantram_giam']}%",
                style: const TextStyle(color: Colors.white70)),
            Text("Điểm cần: ${v['diem_doi']}",
                style: const TextStyle(color: Colors.white70)),
            Text("Hạn: ${v['ngayhethan']}",
                style: const TextStyle(color: Colors.white54)),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: canRedeem ? () => _doiVoucher(v['id_voucher']) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                canRedeem ? Colors.orange.shade700 : Colors.grey.shade800,
          ),
          child: Text(
            canRedeem ? "Đổi ngay" : "Không đủ điểm",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildVoucherDaDoi(Map<String, dynamic> row) {
    final v = row['voucher'];
    final used = row['trangthai'] == "DA_SU_DUNG";

    return Card(
      color: used ? Colors.grey.shade900 : Colors.green.shade900,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(v['ten_voucher'],
            style: const TextStyle(color: Colors.white, fontSize: 18)),
        subtitle: Text(
          used
              ? "Đã sử dụng"
              : "Đổi ngày: ${row['ngaydoi']?.toString()?.substring(0, 10)}",
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
