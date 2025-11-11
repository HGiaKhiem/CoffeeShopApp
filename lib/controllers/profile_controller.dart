import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_coffee_shop_app/entities/khachhang.dart';

class ProfileController {
  final supabase = Supabase.instance.client;

  /// 🔹 Load thông tin khách hàng hiện tại từ UID (nếu không có sẵn)
  Future<KhachHang?> loadCurrentCustomer(KhachHang? existing) async {
    if (existing != null) return existing;

    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return null;

    final data =
        await supabase.from('khachhang').select().eq('UID', uid).maybeSingle();

    return data != null ? KhachHang.fromJson(data) : null;
  }

  /// 🔹 Cập nhật thông tin hồ sơ
  Future<String?> updateProfile({
    required String tenKh,
    required String sdt,
  }) async {
    try {
      final uid = supabase.auth.currentUser?.id;
      if (uid == null) return 'Chưa đăng nhập!';

      await supabase.from('khachhang').update({
        'tenkh': tenKh,
        'sdt': sdt,
        'UpdatedAt': DateTime.now().toIso8601String(),
      }).eq('UID', uid);

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// 🔹 Đổi ảnh đại diện
  Future<String?> changeAvatar({
    KhachHang? kh,
    required String tenKh,
    required String sdt,
  }) async {
    try {
      final uid = supabase.auth.currentUser?.id;
      if (uid == null) return 'Bạn chưa đăng nhập!';

      // Giả sử bạn đã có sẵn ảnh tạm -> upload vào bucket 'avatar'
      // Ở đây chỉ demo thôi, bạn có thể thêm uploadPicker riêng
      final fileName = '${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storagePath = 'avatar/avatar/$fileName';

      // Cập nhật đường dẫn ảnh
      final publicUrl =
          '${supabase.storage.from('avatar').getPublicUrl(storagePath)}';

      await supabase.from('khachhang').update({
        'AvatarURL': publicUrl,
        'UpdatedAt': DateTime.now().toIso8601String(),
      }).eq('UID', uid);

      return publicUrl;
    } catch (e) {
      return 'Lỗi khi đổi ảnh: $e';
    }
  }

  /// 🔹 Lấy hạng thành viên theo điểm
  String getRank(int diemtichluy) {
    if (diemtichluy >= 1000) return 'VIP';
    if (diemtichluy >= 500) return 'Gold';
    if (diemtichluy >= 200) return 'Silver';
    return 'Thường';
  }

  /// 🔹 Đăng xuất
  Future<void> logout() async {
    await supabase.auth.signOut();
  }
}
