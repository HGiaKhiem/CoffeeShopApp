import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_coffee_shop_app/controllers/cart_controller.dart';
import 'package:flutter_coffee_shop_app/ui/screens/qr_scan_screen.dart';

final supabase = Supabase.instance.client;

String formatMoney(double value) {
  return value
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');
}

class CartScreen extends StatefulWidget {
  final int idBan;
  const CartScreen({super.key, required this.idBan});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> _availableVouchers = [];
  int? _selectedVoucherId;
  bool _loadingVouchers = false;

  Future<int> _getIdKhachHangFromUid() async {
    try {
      final uid = supabase.auth.currentUser?.id;

      if (uid == null) {
        debugPrint('⚠️ Không có UID Supabase, dùng khách vãng lai (id = 4)');
        return 4;
      }

      final khach = await supabase
          .from('khachhang')
          .select('id_khachhang')
          .eq('UID', uid)
          .maybeSingle();

      if (khach == null || khach['id_khachhang'] == null) {
        debugPrint('⚠️ Không tìm thấy khách từ UID, dùng id = 4');
        return 4;
      }

      return (khach['id_khachhang'] as num).toInt();
    } catch (e) {
      debugPrint('⚠️ Lỗi khi lấy id_khachhang: $e, dùng id = 4');
      return 4;
    }
  }

  Future<void> _loadAvailableVouchers() async {
    setState(() => _loadingVouchers = true);
    try {
      final idKhach = await _getIdKhachHangFromUid();
      final data = await supabase
          .from('khachhang_voucher')
          .select('id_khv, voucher(ten_voucher, phantram_giam)')
          .eq('id_khachhang', idKhach)
          .eq('trangthai', 'CHUA_SU_DUNG');

      final list = List<Map<String, dynamic>>.from(data);

      final applied = context.read<CartController>().appliedVoucher;
      final appliedId = (applied?['id_khv'] as num?)?.toInt();

      setState(() {
        _availableVouchers = list;
        _selectedVoucherId = (appliedId != null &&
                list.any((v) => (v['id_khv'] as num).toInt() == appliedId))
            ? appliedId
            : null;
      });
    } catch (e) {
      debugPrint('Lỗi load voucher: $e');
    } finally {
      setState(() => _loadingVouchers = false);
    }
  }

  Future<int> _getOrCreateDonHang() async {
    final existing = await supabase
        .from('donhang')
        .select('id_donhang')
        .eq('id_ban', widget.idBan)
        .eq('trangthai', 'CHUA_THANH_TOAN')
        .maybeSingle();
    if (existing != null) return (existing['id_donhang'] as num).toInt();

    final idKhach = await _getIdKhachHangFromUid();
    final inserted = await supabase
        .from('donhang')
        .insert({
          'id_ban': widget.idBan,
          'id_khachhang': idKhach,
          'trangthai': 'CHUA_THANH_TOAN',
          'thoigian': DateTime.now().toIso8601String(),
        })
        .select('id_donhang')
        .single();
    return (inserted['id_donhang'] as num).toInt();
  }

  Future<void> _datMon(BuildContext context, CartController cart) async {
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('🛒 Giỏ hàng trống!')));
      return;
    }

    try {
      final idDonHang = await _getOrCreateDonHang();

      await supabase
          .from('chitietdonhang')
          .delete()
          .eq('id_donhang', idDonHang);

      final rows = cart.items.map((item) {
        final tuychon = {
          'topping': item.tuyChon['topping'],
          'size': item.tuyChon['size'],
          'ghichu': item.tuyChon['ghichu'],
        };

        return {
          'id_donhang': idDonHang,
          'id_mon': item.mon.id_mon,
          'soluong': item.soLuong,
          'giaban': item.giaBan,
          'tuychon_json': tuychon,
        };
      }).toList();

      await supabase.from('chitietdonhang').insert(rows);

      await supabase
          .from('donhang')
          .update({'tongtien': cart.tongTien}).eq('id_donhang', idDonHang);

      await supabase
          .from('ban')
          .update({'trangthai': 'Có khách'}).eq('id_ban', widget.idBan);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('✅ Đặt món thành công!')));
    } catch (e, stack) {
      debugPrint('❌ Lỗi khi đặt món: $e\n$stack');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Lỗi khi đặt món: $e')));
    }
  }

  Future<void> _thanhToanGia(BuildContext context) async {
    final cart = Provider.of<CartController>(context, listen: false);
    try {
      final existing = await supabase
          .from('donhang')
          .select('id_donhang')
          .eq('id_ban', widget.idBan)
          .eq('trangthai', 'CHUA_THANH_TOAN')
          .maybeSingle();

      if (existing == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ Không có đơn hàng để thanh toán!')),
        );
        return;
      }

      final idDonHang = (existing['id_donhang'] as num).toInt();

      await supabase.from('donhang').update({
        'trangthai': 'DA_THANH_TOAN',
        'tongtien': cart.tongTienSauGiam,
      }).eq('id_donhang', idDonHang);

      if (cart.appliedVoucher != null) {
        await supabase.from('khachhang_voucher').update({
          'trangthai': 'DA_SU_DUNG',
          'ngay_sudung': DateTime.now().toIso8601String(),
        }).eq('id_khv', cart.appliedVoucher!['id_khv']);
      }

      await supabase
          .from('ban')
          .update({'trangthai': 'Trống'}).eq('id_ban', widget.idBan);

      cart.clearCart();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('✅ Thanh toán thành công!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Lỗi thanh toán: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAvailableVouchers();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartController>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4E342E),
        title: const Text('Giỏ hàng ☕'),
        centerTitle: true,
      ),
      body: cart.items.isEmpty
          ? const Center(
              child: Text(
                '🛒 Giỏ hàng trống',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Card(
                        color: const Color(0xFF2B2B2B),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              item.mon.hinhanh,
                              width: 55,
                              height: 55,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            item.mon.tenmon,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            'Giá: ${formatMoney(item.giaBan)}đ\nTổng: ${formatMoney(item.giaBan * item.soLuong)}đ',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.white70,
                                ),
                                onPressed: () =>
                                    cart.updateQuantity(item, item.soLuong - 1),
                              ),
                              Text(
                                '${item.soLuong}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.white70,
                                ),
                                onPressed: () =>
                                    cart.updateQuantity(item, item.soLuong + 1),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 20,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2B2B2B),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                  ),
                  child: Column(
                    children: [
                      if (_loadingVouchers)
                        const CircularProgressIndicator(color: Colors.brown)
                      else if (_availableVouchers.isNotEmpty)
                        DropdownButtonFormField<int>(
                          key: ValueKey(_availableVouchers.length),
                          value: _selectedVoucherId,
                          dropdownColor: const Color(0xFF3E3E3E),
                          decoration: InputDecoration(
                            labelText: 'Chọn voucher giảm giá',
                            labelStyle: const TextStyle(color: Colors.white70),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: [
                            // ✅ Tuỳ chọn đầu tiên: Không dùng voucher
                            const DropdownMenuItem<int>(
                              value: -1,
                              child: Text(
                                'Không dùng voucher',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            // ✅ Các voucher thật
                            ..._availableVouchers.map((v) {
                              final id = (v['id_khv'] as num).toInt();
                              final data = v['voucher'] as Map<String, dynamic>;
                              return DropdownMenuItem<int>(
                                value: id,
                                child: Text(
                                  '${data['ten_voucher']} - ${data['phantram_giam']}%',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }),
                          ],
                          onChanged: (id) {
                            setState(() => _selectedVoucherId = id);
                            final cart = context.read<CartController>();

                            if (id == null || id == -1) {
                              cart.removeVoucher(); // 🧹 Bỏ chọn voucher
                              return;
                            }

                            final v = _availableVouchers.firstWhere(
                              (e) => (e['id_khv'] as num).toInt() == id,
                            );
                            final data = v['voucher'] as Map<String, dynamic>;
                            cart.applyVoucher({
                              'id_khv': id,
                              'phantram_giam': data['phantram_giam'],
                              'ten_voucher': data['ten_voucher'],
                            });
                          },
                        ),
                      const SizedBox(height: 10),
                      Text(
                        'Tổng: ${formatMoney(cart.tongTien)}đ',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      if (cart.appliedVoucher != null)
                        Text(
                          '-${cart.appliedVoucher!['phantram_giam']}% (${cart.appliedVoucher!['ten_voucher']})',
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 14,
                          ),
                        ),
                      Text(
                        'Thanh toán: ${formatMoney(cart.tongTienSauGiam)}đ',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async =>
                                  await _datMon(context, cart),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade700,
                              ),
                              icon: const Icon(Icons.fastfood),
                              label: const Text('Đặt món'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async =>
                                  await _thanhToanGia(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade700,
                              ),
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('Thanh toán'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const QrScanScreen(),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown.shade600,
                        ),
                        icon: const Icon(Icons.qr_code_2),
                        label: const Text('Quét mã QR'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
