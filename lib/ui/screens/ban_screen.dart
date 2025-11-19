import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'package:flutter_coffee_shop_app/controllers/auth_controller.dart';

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
  int? _idKhach;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _checkLoggedCustomer();
    await _fetchBan();
  }

  /// Nếu người dùng đã login -> lấy id_khachhang
  Future<void> _checkLoggedCustomer() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final res = await _supabase
        .from('khachhang')
        .select('id_khachhang')
        .eq('email', user.email ?? '')
        .maybeSingle();

    if (res != null) {
      setState(() => _idKhach = res['id_khachhang']);
    }
  }

  /// Lấy thông tin bàn theo qr_token
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi tải bàn: $e")),
        );
      }
    }
  }

  /// Khi khách nhấn "Vào menu quán"
  Future<void> _vaoMenuQuan() async {
    if (_ban == null) return;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('id_ban', _ban!['id_ban']);
    await prefs.setString('qr_token', widget.token);

    // Nếu có tài khoản -> dùng id_khach, nếu không -> dùng 4 (khách vãng lai)
    await prefs.setInt('id_khachhang', _idKhach ?? 4);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  /// Chuyển sang màn đăng nhập (nếu muốn dùng tài khoản riêng)
  Future<void> _chuyenLogin() async {
    if (_ban == null) return;
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('id_ban', _ban!['id_ban']);
    await prefs.setString('qr_token', widget.token);

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
          ? const Center(child: CircularProgressIndicator(color: Colors.brown))
          : _ban == null
              ? const Center(
                  child: Text(
                    "Không tìm thấy bàn!",
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Stack(
      children: [
        // Nền gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E1F17), Color(0xFF0D0A08)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        // Hiệu ứng blur overlay
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(color: Colors.black.withOpacity(0.2)),
        ),

        // Nội dung
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon bàn / cafe
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

                // Số bàn
                Text(
                  "Bàn số ${_ban!['soban']}",
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 10),

                // Trạng thái chỉ để tham khảo – không dùng để chặn khách
                Text(
                  "Trạng thái: ${_ban!['trangthai']}",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 40),

                // Nút vào menu
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _vaoMenuQuan,
                    icon:
                        const Icon(Icons.restaurant_menu, color: Colors.white),
                    label: const Text(
                      "Vào menu quán",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown.shade600,
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Nút đăng nhập
                OutlinedButton.icon(
                  onPressed: _chuyenLogin,
                  icon: const Icon(Icons.login, color: Colors.white70),
                  label: const Text(
                    "Đăng nhập tài khoản riêng",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
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

                const Text(
                  "Quét mã QR trên bàn để gọi món.\n",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
