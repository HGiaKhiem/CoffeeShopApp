import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_coffee_shop_app/controllers/auth_controller.dart';
import 'package:flutter_coffee_shop_app/ui/screens/login_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final PageController _pageController = PageController();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  int _currentPage = 0;
  bool _loading = false;
  String? _error;
  Timer? _timer;

  // 👁 Trạng thái ẩn/hiện mật khẩu
  bool _showPass = false;
  bool _showConfirm = false;

  final List<String> _backgrounds = [
    'https://i.imgur.com/f1ZkmgC.jpg',
    'https://i.imgur.com/IjY028x.jpg',
    'https://i.imgur.com/nnroE8z.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % _backgrounds.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email.trim());
  }

  Future<void> _register() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim().replaceAll('"', '');
    final phone = _phoneCtrl.text.trim();
    final password = _passCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _error = '⚠️ Vui lòng nhập đầy đủ thông tin';
        _loading = false;
      });
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() {
        _error = '❌ Địa chỉ email không hợp lệ';
        _loading = false;
      });
      return;
    }

    if (password != confirm) {
      setState(() {
        _error = '❌ Mật khẩu xác nhận không khớp';
        _loading = false;
      });
      return;
    }

    final error = await AuthController.signUp(
      email: email,
      password: password,
      tenKh: name,
      sdt: phone,
    );

    if (!mounted) return;

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green.shade600,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          content: const Text(
            '✅ Đăng ký thành công! Hãy đăng nhập.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      setState(() => _error = error);
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background auto slide
          PageView.builder(
            controller: _pageController,
            itemCount: _backgrounds.length,
            itemBuilder: (context, index) => Image.network(
              _backgrounds[index],
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Container(color: Colors.black.withOpacity(0.6)),

          // Dots indicator
          Align(
            alignment: const Alignment(0, 0.8),
            child: SmoothPageIndicator(
              controller: _pageController,
              count: _backgrounds.length,
              effect: const ExpandingDotsEffect(
                activeDotColor: Colors.white,
                dotColor: Colors.white54,
                dotHeight: 5,
                dotWidth: 10,
              ),
            ),
          ),

          // Register form
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Tạo tài khoản ☕',
                          style: TextStyle(
                            fontSize: 26,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildBlurInput(
                          controller: _nameCtrl,
                          hint: 'Họ tên',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
                        _buildBlurInput(
                          controller: _emailCtrl,
                          hint: 'Email',
                          icon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 16),
                        _buildBlurInput(
                          controller: _phoneCtrl,
                          hint: 'Số điện thoại',
                          icon: Icons.phone_outlined,
                        ),
                        const SizedBox(height: 16),
                        // 🔐 Mật khẩu có icon con mắt
                        _buildBlurInput(
                          controller: _passCtrl,
                          hint: 'Mật khẩu',
                          icon: Icons.lock_outline,
                          obscure: !_showPass,
                          toggle: () => setState(() => _showPass = !_showPass),
                          show: _showPass,
                        ),
                        const SizedBox(height: 16),
                        // 🔐 Xác nhận mật khẩu có icon con mắt
                        _buildBlurInput(
                          controller: _confirmCtrl,
                          hint: 'Xác nhận mật khẩu',
                          icon: Icons.lock_outline,
                          obscure: !_showConfirm,
                          toggle: () =>
                              setState(() => _showConfirm = !_showConfirm),
                          show: _showConfirm,
                        ),
                        const SizedBox(height: 20),
                        if (_error != null)
                          Text(
                            _error!,
                            style: const TextStyle(color: Colors.redAccent),
                            textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: _loading ? null : _register,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 50,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                colors: [Color(0xffd7a36f), Color(0xff8b5e34)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: _loading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text(
                                      'Tạo tài khoản',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          ),
                          child: const Text(
                            'Đã có tài khoản? Đăng nhập ngay',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Input field có hiệu ứng mờ + icon con mắt (nếu là mật khẩu)
  Widget _buildBlurInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    bool? show,
    VoidCallback? toggle,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white70),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscure,
                  keyboardType: hint == 'Số điện thoại'
                      ? TextInputType.phone
                      : TextInputType.text,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (toggle != null)
                IconButton(
                  onPressed: toggle,
                  icon: Icon(
                    (show ?? false) ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white70,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
