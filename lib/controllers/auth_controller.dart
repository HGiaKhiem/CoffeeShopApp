import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController {
  static final supabase = Supabase.instance.client;

  /// ------------------------
  ///  Đăng nhập
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
    } catch (e) {
      return e.toString();
    }
  }

  /// ------------------------
  ///  Đăng ký
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
    } catch (e) {
      return e.toString();
    }
  }

  /// ------------------------
  ///  Đăng xuất
  static Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  /// ------------------------
  ///  Lấy thông tin user hiện tại từ auth
  static User? get currentUser => supabase.auth.currentUser;

  /// ------------------------
  /// Lấy thông tin khách hàng từ bảng public.khachhang
  static Future<Map<String, dynamic>?> getKhachHangInfo() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return null;

    final data =
        await supabase.from('khachhang').select().eq('UID', uid).maybeSingle();

    return data;
  }

  /// ------------------------
  /// Cập nhật thông tin khách hàng (VD: tên, số điện thoại)
  static Future<String?> updateKhachHang({
    required String tenKh,
    String? sdt,
    String? avatarUrl,
  }) async {
    try {
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid == null) return 'Chưa đăng nhập';

      final updates = <String, dynamic>{
        'tenkh': tenKh,
        if (sdt != null) 'sdt': sdt,
        if (avatarUrl != null) 'AvatarURL': avatarUrl,
      };

      await Supabase.instance.client
          .from('khachhang')
          .update(updates)
          .eq('UID', uid);

      return null;
    } catch (e) {
      return e.toString();
    }
  }


    static Future<void> signOutAnonymous() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      print('Lỗi khi signOut: $e');
    }
  }
}
