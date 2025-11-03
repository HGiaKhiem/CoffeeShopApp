import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_coffee_shop_app/controllers/auth_controller.dart';
import 'package:flutter_coffee_shop_app/ui/screens/home_screen.dart';
import 'package:flutter_coffee_shop_app/ui/screens/register_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final PageController _pageController = PageController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  int _currentPage = 0;
  bool _isLoading = false;
  String? _error;
  bool _isFormValid = false; // 🟢 Thêm state để kiểm tra form

  Timer? _timer;

  final List<String> _backgrounds = [
    'https://i.imgur.com/f1ZkmgC.jpg',
    'https://i.imgur.com/IjY028x.jpg',
    'https://i.imgur.com/nnroE8z.jpg',
  ];

  @override
  void initState() {
    super.initState();

    // Khi người dùng nhập email hoặc pass, cập nhật form validity
    _emailCtrl.addListener(_validateForm);
    _passCtrl.addListener(_validateForm);

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % _backgrounds.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _validateForm() {
    final isValid =
        _emailCtrl.text.trim().isNotEmpty && _passCtrl.text.trim().isNotEmpty;
    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_isFormValid || _isLoading) return; // chan khi k co du lieu

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final error = await AuthController.signIn(
      _emailCtrl.text.trim(),
      _passCtrl.text.trim(),
    );

    if (error == null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      setState(() => _error = error as String?);
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          PageView.builder(
            controller: _pageController,
            itemCount: _backgrounds.length,
            itemBuilder: (context, index) => AnimatedSwitcher(
              duration: const Duration(seconds: 1),
              child: Image.network(
                _backgrounds[index],
                key: ValueKey(_backgrounds[index]),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.6)),

          // Smooth indicator
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

          // Login form
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
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Welcome Back ☕',
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Email
                        _buildBlurInput(
                          controller: _emailCtrl,
                          hint: 'Email',
                          icon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 16),

                        // Password
                        _buildBlurInput(
                          controller: _passCtrl,
                          hint: 'Mật khẩu',
                          icon: Icons.lock_outline,
                          obscure: true,
                        ),
                        const SizedBox(height: 24),

                        if (_error != null)
                          Text(_error!,
                              style: const TextStyle(color: Colors.redAccent)),

                        const SizedBox(height: 10),

                        // Login Button (disabled nếu chưa nhập)
                        GestureDetector(
                          onTap: _isFormValid && !_isLoading ? _login : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 50,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: _isFormValid
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xffd7a36f),
                                        Color(0xff8b5e34)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : const LinearGradient(
                                      colors: [
                                        Colors.grey,
                                        Colors.grey,
                                      ],
                                    ),
                              boxShadow: [
                                if (_isFormValid)
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                              ],
                            ),
                            child: Center(
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : Text(
                                      'Đăng nhập',
                                      style: TextStyle(
                                        color: _isFormValid
                                            ? Colors.white
                                            : Colors.white60,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Register link
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegisterScreen()),
                          ),
                          child: const Text(
                            'Chưa có tài khoản? Đăng ký ngay',
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

  Widget _buildBlurInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
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
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(color: Colors.white54),
                    border: InputBorder.none,
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
