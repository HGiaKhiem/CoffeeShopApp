import 'package:flutter/material.dart';
import 'package:flutter_coffee_shop_app/controllers/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();

  bool _loadingLink = true;
  bool _updating = false;
  String? _message;

  bool _showPass = false;
  bool _showPass2 = false;

  @override
  void initState() {
    super.initState();
    _verifyAndRestoreSession();
  }

  /// ✅ Kiểm tra và khôi phục session từ link Supabase
  Future<void> _verifyAndRestoreSession() async {
    final uri = Uri.base;
    final code = uri.queryParameters['code'];
    final type = uri.queryParameters['type'];

    try {
      if (code != null && type == 'recovery') {
        await Supabase.instance.client.auth.exchangeCodeForSession(code);
      }
      setState(() {
        _loadingLink = false;
        _message = null;
      });
    } catch (e) {
      setState(() {
        _loadingLink = false;
        _message = '❌ Liên kết không hợp lệ hoặc đã hết hạn.';
      });
    }
  }

  /// ✅ Gửi mật khẩu mới
  Future<void> _updatePassword() async {
    final pass = _passCtrl.text.trim();
    final confirm = _pass2Ctrl.text.trim();

    if (pass.isEmpty || confirm.isEmpty) {
      setState(() => _message = '⚠️ Vui lòng nhập đầy đủ mật khẩu.');
      return;
    }
    if (pass != confirm) {
      setState(() => _message = '⚠️ Mật khẩu nhập lại không khớp.');
      return;
    }
    if (pass.length < 6) {
      setState(() => _message = '⚠️ Mật khẩu phải có ít nhất 6 ký tự.');
      return;
    }

    setState(() {
      _updating = true;
      _message = null;
    });

    final error = await AuthController.resetPassword(pass);

    setState(() {
      _updating = false;
      _message =
          error ?? '✅ Đặt lại mật khẩu thành công! Bạn có thể đăng nhập lại.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4E342E),
        title: const Text('Đặt lại mật khẩu'),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _loadingLink
                ? const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Đang xác thực liên kết...',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_outline,
                          color: Colors.white70, size: 80),
                      const SizedBox(height: 24),
                      if (_message != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            _message!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _message!.startsWith('✅')
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      TextField(
                        controller: _passCtrl,
                        obscureText: !_showPass,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu mới',
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon:
                              const Icon(Icons.lock, color: Colors.white70),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPass
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white70,
                            ),
                            onPressed: () =>
                                setState(() => _showPass = !_showPass),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _pass2Ctrl,
                        obscureText: !_showPass2,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Nhập lại mật khẩu',
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: Colors.white70),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPass2
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white70,
                            ),
                            onPressed: () =>
                                setState(() => _showPass2 = !_showPass2),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _updating ? null : _updatePassword,
                          icon: _updating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.refresh),
                          label: Text(
                            _updating ? 'Đang cập nhật...' : 'Đặt lại mật khẩu',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
