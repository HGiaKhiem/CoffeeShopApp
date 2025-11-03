import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_coffee_shop_app/controllers/home_controller.dart';
import 'package:flutter_coffee_shop_app/controllers/auth_controller.dart';
import 'package:flutter_coffee_shop_app/entities/khachhang.dart';
import 'package:flutter_coffee_shop_app/ui/screens/login_screen.dart';
import 'package:flutter_coffee_shop_app/ui/theme/app_theme.dart';

const String kDefaultAvatar =
    'https://rubeafovywlrgxblfmlr.supabase.co/storage/v1/object/public/avatar/avatar.png';

class ProfileScreen extends StatefulWidget {
  final KhachHang? customer; // truyền sẵn từ AppBar (nếu có)
  const ProfileScreen({super.key, this.customer});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  KhachHang? _kh;
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _uploadingAvatar = false;

  String _avatarUrl = kDefaultAvatar;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final data = widget.customer ?? await HomeController.getCurrentCustomer();
    setState(() {
      _kh = data;
      _nameCtrl.text = data?.tenkh ?? '';
      _phoneCtrl.text = data?.sdt ?? '';
      _avatarUrl = data?.avatarURL ?? kDefaultAvatar;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        backgroundColor: bg,
        content: Text(msg, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Future<XFile?> _pickImage() async {
    final picker = ImagePicker();
    // Web: chỉ gallery; Mobile: bạn có thể đổi thành camera nếu muốn
    return picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
  }

  Future<void> _changeAvatar() async {
    try {
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid == null) {
        _snack('Bạn chưa đăng nhập', Colors.red.shade700);
        return;
      }

      final XFile? file = await _pickImage();
      if (file == null) return;

      setState(() => _uploadingAvatar = true);

      final Uint8List bytes = await file.readAsBytes();
      final ext = file.name.split('.').last.toLowerCase();
      // Lưu theo thư mục UID để policy chặt chẽ
      final path = 'avatar/$uid/${DateTime.now().millisecondsSinceEpoch}.$ext';

      final storage = Supabase.instance.client.storage.from('avatar');
      await storage.uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(upsert: true, cacheControl: '3600'),
      );
      final publicUrl = storage.getPublicUrl(path);

      // Cập nhật DB
      final err = await AuthController.updateKhachHang(
        tenKh: _nameCtrl.text.trim().isEmpty
            ? (_kh?.tenkh ?? '')
            : _nameCtrl.text.trim(),
        sdt: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        avatarUrl: publicUrl,
      );
      if (err != null) {
        setState(() => _uploadingAvatar = false);
        _snack('Lỗi cập nhật avatar: $err', Colors.red.shade700);
        return;
      }

      setState(() {
        _avatarUrl = publicUrl;
        _uploadingAvatar = false;
      });
      _snack('Đã cập nhật ảnh đại diện', Colors.green.shade600);
    } catch (e) {
      setState(() => _uploadingAvatar = false);
      _snack('Lỗi: $e', Colors.red.shade700);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    final err = await AuthController.updateKhachHang(
      tenKh: _nameCtrl.text.trim().isEmpty
          ? (_kh?.tenkh ?? '')
          : _nameCtrl.text.trim(),
      sdt: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      // Avatar giữ nguyên; đổi bằng nút Đổi ảnh
    );
    setState(() => _saving = false);

    if (err == null) {
      _snack('Đã lưu thông tin', Colors.green.shade600);
      _bootstrap();
    } else {
      _snack('Lỗi: $err', Colors.red.shade700);
    }
  }

  Future<void> _logout() async {
    await AuthController.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Apptheme.backgroundColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Apptheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Hồ sơ khách hàng'),
        backgroundColor: Colors.brown,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar + đổi ảnh
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(80),
                  child: Image.network(
                    _avatarUrl,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Image.network(
                      kDefaultAvatar,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  onPressed: _uploadingAvatar ? null : _changeAvatar,
                  icon: _uploadingAvatar
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.camera_alt,
                          size: 18, color: Colors.white),
                  label: Text(
                    _uploadingAvatar ? 'Đang tải...' : 'Đổi ảnh',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _field(
              label: 'Họ tên',
              controller: _nameCtrl,
              hint: 'Nhập họ tên',
              keyboard: TextInputType.name,
            ),
            const SizedBox(height: 12),

            _field(
              label: 'Số điện thoại',
              controller: _phoneCtrl,
              hint: 'Nhập số điện thoại',
              keyboard: TextInputType.phone,
            ),
            const SizedBox(height: 12),

            _readonly(label: 'Email', value: _kh?.email ?? 'Chưa cập nhật'),
            const SizedBox(height: 12),

            _readonly(
                label: 'Điểm tích lũy', value: '${_kh?.diemtichluy ?? 0} điểm'),
            _readonly(
                label: 'Hạng thành viên',
                value: _rankOf(_kh?.diemtichluy ?? 0)),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Apptheme.buttonBackground2Color,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _saving ? null : _saveProfile,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save, color: Colors.white),
                label: Text(
                  _saving ? 'Đang lưu...' : 'Lưu thay đổi',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------- widgets phụ ----------
  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.white.withOpacity(0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _readonly({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  String _rankOf(int p) {
    if (p >= 1000) return 'VIP';
    if (p >= 500) return 'Gold';
    if (p >= 200) return 'Silver';
    return 'Thường';
  }
}
