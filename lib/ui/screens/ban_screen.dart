import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_coffee_shop_app/controllers/auth_controller.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class BanScreen extends StatefulWidget {
  final String token;
  const BanScreen({super.key, required this.token});

  @override
  State<BanScreen> createState() => _BanScreenState();
}

class _BanScreenState extends State<BanScreen> {
  final _supabase = Supabase.instance.client;
  Map<String, dynamic>? _ban;
  bool _loading = true;
  bool _hasCustomer = false;
  int? _idKhach; // Nếu user đã login

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      // ✅ Lấy id_khach từ bảng khachhang theo email đăng nhập
      final res = await _supabase
          .from('khachhang')
          .select('id_khachhang')
          .eq('email', user.email ?? '')
          .maybeSingle();

      setState(() {
        _hasCustomer = true;
        _idKhach = res?['id_khachhang'];
      });
    }
    await _fetchBan();
  }

  /// ✅ Lấy thông tin bàn từ Supabase
  Future<void> _fetchBan() async {
    try {
      final res = await _supabase
          .from('ban')
          .select('id_ban, soban, trangthai')
          .eq('qr_token', widget.token)
          .maybeSingle();

      setState(() {
        _ban = res;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải bàn: $e')),
      );
    }
  }

  /// ✅ Khi khách vào menu quán
  Future<void> _vaoMenuQuan() async {
    if (_ban == null) return;

    final prefs = await SharedPreferences.getInstance();
    final int idBan = _ban!['id_ban'];
    final String trangThai = _ban!['trangthai'];

    // ❌ Nếu bàn có khách thì chặn lại
    if (trangThai != 'Trống') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('❌ Bàn này đang có khách, vui lòng chọn bàn khác.'),
        ),
      );
      return;
    }

    // ✅ Nếu chưa login thì set idKhach = 4 (Khachdattaiban)
    final int idKhach = _idKhach ?? 4;

    // ✅ Cập nhật trạng thái bàn
    await _supabase
        .from('ban')
        .update({'trangthai': 'Có khách'}).eq('id_ban', idBan);

    // ✅ Lưu id bàn + khách vào bộ nhớ cục bộ
    await prefs.setInt('id_ban', idBan);
    await prefs.setInt('id_khachhang', idKhach);

    // Đảm bảo session được clear nếu là khách không đăng nhập
    await AuthController.signOut();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  /// ✅ Nếu khách muốn đăng nhập tài khoản riêng
  Future<void> _chuyenLogin() async {
    if (_ban == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('id_ban', _ban!['id_ban']);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1015),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.brown),
            )
          : _ban == null
              ? const Center(
                  child: Text(
                    'Không tìm thấy bàn!',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                )
              : Stack(
                  children: [
                    // 🌈 Nền gradient mượt
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF2E1F17), Color(0xFF0D0A08)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),

                    // Blur overlay nhẹ
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(color: Colors.black.withOpacity(0.2)),
                    ),

                    // Nội dung
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(26),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Colors.brown.shade100.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.brown.shade400,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.local_cafe_rounded,
                                size: 60,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Thông tin bàn
                            Text(
                              'Bàn số ${_ban!['soban']}',
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Trạng thái: ${_ban!['trangthai']}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Nút hành động
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _vaoMenuQuan,
                                icon: const Icon(Icons.restaurant_menu,
                                    color: Colors.white),
                                label: Text(
                                  _ban!['trangthai'] == 'Trống'
                                      ? 'Vào menu quán'
                                      : 'Bàn đang có khách',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _ban!['trangthai'] == 'Trống'
                                      ? Colors.brown.shade600
                                      : Colors.grey.shade700,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  shadowColor:
                                      Colors.brown.shade900.withOpacity(0.6),
                                  elevation: 8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            OutlinedButton.icon(
                              onPressed: _chuyenLogin,
                              icon: const Icon(Icons.login,
                                  color: Colors.white70),
                              label: const Text(
                                'Đăng nhập tài khoản riêng',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 16),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.brown.shade300),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 25),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),

                            Text(
                              'Quét mã QR trên bàn để gọi món.\nSau khi thanh toán, bàn sẽ được làm mới.',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
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
