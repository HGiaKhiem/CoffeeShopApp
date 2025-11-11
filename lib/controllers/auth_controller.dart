import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class AuthController {
  static final supabase = Supabase.instance.client;

  // ------------------------
  //  Đăng nhập
  static Future<String?> signIn(String email, String password) async {
    try {
      final res = await supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (res.session != null) {
        return null; // ✅ Thành công
      } else {
        return 'Sai email hoặc mật khẩu';
      }
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // ------------------------
  //  Đăng ký
  static Future<String?> signUp({
    required String email,
    required String password,
    required String tenKh,
    String? sdt,
  }) async {
    try {
      final res = await supabase.auth.signUp(
        email: email.trim(),
        password: password.trim(),
        data: {
          'full_name': tenKh,
          'phone': sdt,
        },
      );

      if (res.user != null) {
        return null; // ✅ Thành công
      } else {
        return 'Không thể tạo tài khoản';
      }
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // ------------------------
  //  Đăng xuất
  static Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // ------------------------
  //  Lấy thông tin user hiện tại
  static User? get currentUser => supabase.auth.currentUser;

  // ------------------------
  //  Lấy thông tin khách hàng từ bảng public.khachhang
  static Future<Map<String, dynamic>?> getKhachHangInfo() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return null;

    final data =
        await supabase.from('khachhang').select().eq('UID', uid).maybeSingle();

    return data;
  }

  // ------------------------
  //  Cập nhật thông tin khách hàng
  static Future<String?> updateKhachHang({
    required String tenKh,
    String? sdt,
    String? avatarUrl,
  }) async {
    try {
      final uid = supabase.auth.currentUser?.id;
      if (uid == null) return 'Chưa đăng nhập';

      final updates = <String, dynamic>{
        'tenkh': tenKh,
        if (sdt != null) 'sdt': sdt,
        if (avatarUrl != null) 'AvatarURL': avatarUrl,
      };

      await supabase.from('khachhang').update(updates).eq('UID', uid);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ------------------------
  //  Gửi email đặt lại mật khẩu
  static Future<String?> sendResetPasswordEmail(String email) async {
    try {
      // 🔹 Luồng chuẩn Supabase (2025):
      // Dùng redirectTo để mở trang /reset-password của web đã deploy
      const redirectUrl = 'https://coffeeshop-app-bb920.web.app/reset-password';

      await supabase.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: redirectUrl,
      );

      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // ------------------------
  //  Cập nhật mật khẩu mới (sau khi xác thực code từ email)
  static Future<String?> resetPassword(String newPassword) async {
    try {
      await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // ------------------------
  //  Xử lý xác thực từ link (dùng trong ResetPasswordScreen)
  static Future<String?> handleRecoveryLink(Uri uri) async {
    try {
      final code = uri.queryParameters['code'];
      final type = uri.queryParameters['type'];

      if (code != null && type == 'recovery') {
        await supabase.auth.exchangeCodeForSession(code);
        return null; // ✅ Thành công
      } else {
        return 'Liên kết không hợp lệ hoặc đã hết hạn.';
      }
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }
}
