import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_coffee_shop_app/controllers/cart_controller.dart';
import 'package:flutter_coffee_shop_app/entities/cart_item.dart';
import 'package:flutter_coffee_shop_app/ui/screens/qr_scan_screen.dart';

final supabase = Supabase.instance.client;

class CartScreen extends StatelessWidget {
  final int idBan;
  final int idKhach;

  const CartScreen({
    super.key,
    required this.idBan,
    required this.idKhach,
  });

  /// 🔹 Lấy hoặc tạo đơn hàng mới (CHUA_THANH_TOAN)
  Future<int> _getOrCreateDonHang() async {
    final existing = await supabase
        .from('donhang')
        .select('id_donhang')
        .eq('id_ban', idBan)
        .eq('trangthai', 'CHUA_THANH_TOAN')
        .maybeSingle();

    if (existing != null) return existing['id_donhang'] as int;

    final insert = await supabase
        .from('donhang')
        .insert({
          'id_ban': idBan,
          'id_khachhang': idKhach,
          'trangthai': 'CHUA_THANH_TOAN',
          'thoigian': DateTime.now().toIso8601String(),
        })
        .select('id_donhang')
        .single();

    return insert['id_donhang'] as int;
  }

  /// 🟤 Đặt món (insert chi tiết vào CSDL)
  Future<void> _datMon(BuildContext context, CartController cart) async {
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🛒 Giỏ hàng trống!')),
      );
      return;
    }

    try {
      final idDonHang = await _getOrCreateDonHang();

      // Xóa chi tiết cũ nếu có
      await supabase.from('chitietdonhang').delete().eq('id_donhang', idDonHang);

      // Insert món mới
      final data = cart.items.map((i) {
        return {
          'id_donhang': idDonHang,
          'id_mon': i.mon.id_mon,
          'soluong': i.soLuong,
          'giaban': i.giaBan,
          'tuychon_json': i.tuyChon,
        };
      }).toList();
      await supabase.from('chitietdonhang').insert(data);

      await supabase
          .from('donhang')
          .update({'tongtien': cart.tongTien}).eq('id_donhang', idDonHang);

      await supabase
          .from('ban')
          .update({'trangthai': 'Có khách'}).eq('id_ban', idBan);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Đặt món thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Lỗi khi đặt món: $e')),
      );
    }
  }

  /// 🟢 Thanh toán giả (update trạng thái)
/// 🟢 Thanh toán giả (update trạng thái + clear giỏ)
/// 🟢 Thanh toán giả (update trạng thái + clear giỏ)
Future<void> _thanhToanGia(BuildContext context) async {
  final cart = Provider.of<CartController>(context, listen: false);

  try {
    final existing = await supabase
        .from('donhang')
        .select('id_donhang')
        .eq('id_ban', idBan)
        .eq('trangthai', 'CHUA_THANH_TOAN')
        .maybeSingle();

    if (existing == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Không có đơn hàng để thanh toán!')),
      );
      return;
    }

    final idDonHang = existing['id_donhang'];

    // ✅ Cập nhật trạng thái đơn & bàn
    await supabase
        .from('donhang')
        .update({'trangthai': 'DA_THANH_TOAN'})
        .eq('id_donhang', idDonHang);

    await supabase
        .from('ban')
        .update({'trangthai': 'Trống'})
        .eq('id_ban', idBan);

    // ✅ Xóa giỏ hàng trong app
    cart.clearCart();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Thanh toán thành công, giỏ hàng đã được làm trống!'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('❌ Lỗi thanh toán: $e')),
    );
  }
}


  /// 🟣 Mở màn hình quét QR
  void _openQrScan(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QrScanScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartController>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4E342E),
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.brown.shade600,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Quay lại',
          ),
        ),
        title: const Text(
          'Giỏ hàng của bạn ☕',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
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
                // Danh sách món
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Card(
                        color: const Color(0xFF2B2B2B),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              item.mon.hinhanh,
                              width: 55,
                              height: 55,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.local_cafe,
                                      color: Colors.white70),
                            ),
                          ),
                          title: Text(
                            item.mon.tenmon,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Giá: ${item.giaBan.toStringAsFixed(0)}đ\nTổng: ${(item.giaBan * item.soLuong).toStringAsFixed(0)}đ',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline,
                                    color: Colors.white70),
                                onPressed: () =>
                                    cart.updateQuantity(item, item.soLuong - 1),
                              ),
                              Text(
                                '${item.soLuong}',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline,
                                    color: Colors.white70),
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

                // Tổng cộng + nút hành động
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2B2B2B),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(22)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Tổng cộng: ${cart.tongTien.toStringAsFixed(0)}đ',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async =>
                                  await _datMon(context, cart),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade700,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.fastfood,
                                  color: Colors.white),
                              label: const Text('Đặt món',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async =>
                                  await _thanhToanGia(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade700,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.check_circle_outline,
                                  color: Colors.white),
                              label: const Text('Thanh toán',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => _openQrScan(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.qr_code_2, color: Colors.white),
                        label: const Text('Quét mã QR',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
