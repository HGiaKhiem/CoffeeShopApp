import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_coffee_shop_app/controllers/auth_controller.dart';
import 'package:flutter_coffee_shop_app/ui/screens/home_screen.dart';
import 'package:flutter_coffee_shop_app/ui/screens/register_screen.dart';
import 'package:flutter_coffee_shop_app/ui/screens/reset_password_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final PageController _pageController = PageController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _isFormValid = false;
  bool _isLoading = false;
  bool _isObscure = true;
  bool _rememberMe = false;
  String? _error;
  int _currentPage = 0;
  Timer? _timer;

  final List<String> _backgrounds = [
    'https://i.imgur.com/f1ZkmgC.jpg',
    'https://i.imgur.com/IjY028x.jpg',
    'https://i.imgur.com/nnroE8z.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedLogin();
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
    final valid =
        _emailCtrl.text.trim().isNotEmpty && _passCtrl.text.trim().isNotEmpty;
    if (valid != _isFormValid) setState(() => _isFormValid = valid);
  }

  Future<void> _loadSavedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');
    final savedPass = prefs.getString('password');
    if (savedEmail != null && savedPass != null) {
      _emailCtrl.text = savedEmail;
      _passCtrl.text = savedPass;
      _rememberMe = true;
      _validateForm();
    }
  }

  Future<void> _saveLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('email', _emailCtrl.text.trim());
      await prefs.setString('password', _passCtrl.text.trim());
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
    }
  }

  Future<void> _login() async {
    if (!_isFormValid || _isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final error = await AuthController.signIn(
      _emailCtrl.text.trim(),
      _passCtrl.text.trim(),
    );

    if (error == null) {
      await _saveLogin();
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

  Future<void> _forgotPassword() async {
    if (_emailCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('⚠️ Vui lòng nhập email để đặt lại mật khẩu')));
      return;
    }

    final error =
        await AuthController.sendResetPasswordEmail(_emailCtrl.text.trim());

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('📩 Email đặt lại mật khẩu đã được gửi')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('❌ $error')));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
                        const Text('Welcome Back ☕',
                            style: TextStyle(
                                fontSize: 28,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        _buildBlurInput(
                            controller: _emailCtrl,
                            hint: 'Email',
                            icon: Icons.email_outlined),
                        const SizedBox(height: 16),
                        _buildBlurInput(
                          controller: _passCtrl,
                          hint: 'Mật khẩu',
                          icon: Icons.lock_outline,
                          obscure: _isObscure,
                          suffix: IconButton(
                            icon: Icon(
                              _isObscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white70,
                            ),
                            onPressed: () =>
                                setState(() => _isObscure = !_isObscure),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (v) =>
                                      setState(() => _rememberMe = v ?? false),
                                  checkColor: Colors.brown,
                                ),
                                const Text('Ghi nhớ đăng nhập',
                                    style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const ForgetPasswordScreen()),
                              ),
                              child: const Text('Quên mật khẩu?',
                                  style: TextStyle(
                                      color: Colors.orangeAccent,
                                      fontWeight: FontWeight.w500)),
                            )
                          ],
                        ),
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(_error!,
                                style:
                                    const TextStyle(color: Colors.redAccent)),
                          ),
                        const SizedBox(height: 10),
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
                                      colors: [Colors.grey, Colors.grey]),
                            ),
                            child: Center(
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : Text('Đăng nhập',
                                      style: TextStyle(
                                        color: _isFormValid
                                            ? Colors.white
                                            : Colors.white60,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      )),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegisterScreen()),
                          ),
                          child: const Text('Chưa có tài khoản? Đăng ký ngay',
                              style: TextStyle(color: Colors.white70)),
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
    Widget? suffix,
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
              if (suffix != null) suffix,
            ],
          ),
        ),
      ),
    );
  }
}
