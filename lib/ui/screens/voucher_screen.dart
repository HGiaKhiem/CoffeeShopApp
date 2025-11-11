import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class VoucherScreen extends StatefulWidget {
  final int idKhach;

  const VoucherScreen({super.key, required this.idKhach});

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _vouchers = [];
  int _diemTichLuy = 0;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _loadDiemTichLuy();
    await _loadVoucherList();
  }

  /// 🔹 Lấy điểm tích lũy hiện tại của khách hàng
  Future<void> _loadDiemTichLuy() async {
    try {
      final data = await supabase
          .from('khachhang')
          .select('diemtichluy')
          .eq('id_khachhang', widget.idKhach)
          .maybeSingle();

      if (data != null) {
        setState(() {
          _diemTichLuy = (data['diemtichluy'] as num?)?.toInt() ?? 0;
        });
      }
    } catch (e) {
      debugPrint('❌ Lỗi load điểm tích lũy: $e');
    }
  }

  /// 🔹 Load danh sách voucher có thể đổi
  Future<void> _loadVoucherList() async {
    try {
      setState(() => _loading = true);

      final data = await supabase
          .from('voucher')
          .select(
              'id_voucher, ten_voucher, phantram_giam, diem_doi, ngayhethan')
          .eq('trangthai', true)
          .order('diem_doi', ascending: true);

      setState(() {
        _vouchers = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      debugPrint('❌ Lỗi load voucher: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Lỗi tải danh sách voucher: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  /// 🔹 Gọi RPC đổi điểm sang voucher
  Future<void> _doiVoucher(int idVoucher) async {
    try {
      final result = await supabase.rpc(
        'doi_diem_sang_voucher',
        params: {
          'p_id_khach': widget.idKhach,
          'p_id_voucher': idVoucher,
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.toString()),
          backgroundColor: Colors.green.shade700,
        ),
      );

      // Cập nhật lại điểm và voucher sau khi đổi
      await _bootstrap();
    } catch (e) {
      debugPrint('❌ Lỗi khi đổi voucher: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Lỗi khi đổi voucher: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('🎁 Đổi Voucher'),
        centerTitle: true,
        backgroundColor: Colors.brown.shade700,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.brown),
            )
          : Column(
              children: [
                // 🧾 Header: điểm tích lũy hiện tại
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.brown.shade600,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Điểm tích lũy hiện tại',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_diemTichLuy điểm',
                        style: const TextStyle(
                          fontSize: 26,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 📋 Danh sách voucher
                Expanded(
                  child: _vouchers.isEmpty
                      ? const Center(
                          child: Text(
                            '😕 Hiện chưa có voucher nào khả dụng.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _vouchers.length,
                          itemBuilder: (context, index) {
                            final v = _vouchers[index];
                            final canRedeem =
                                _diemTichLuy >= (v['diem_doi'] as num);

                            return Card(
                              color: const Color(0xFF2B2B2B),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                title: Text(
                                  v['ten_voucher'] ?? 'Không tên',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 6),
                                    Text(
                                      'Giảm: ${v['phantram_giam']}%',
                                      style: const TextStyle(
                                          color: Colors.white70),
                                    ),
                                    Text(
                                      'Điểm cần: ${v['diem_doi']} điểm',
                                      style: const TextStyle(
                                          color: Colors.white70),
                                    ),
                                    Text(
                                      'Hết hạn: ${v['ngayhethan'] ?? 'Không xác định'}',
                                      style: const TextStyle(
                                          color: Colors.white54),
                                    ),
                                  ],
                                ),
                                trailing: ElevatedButton.icon(
                                  onPressed: canRedeem
                                      ? () => _doiVoucher(v['id_voucher'])
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: canRedeem
                                        ? Colors.orange.shade700
                                        : Colors.grey,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: const Icon(Icons.redeem,
                                      color: Colors.white),
                                  label: Text(
                                    canRedeem ? 'Đổi ngay' : 'Không đủ điểm',
                                    style:
                                        const TextStyle(color: Colors.white70),
                                  ),
                                ),
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
