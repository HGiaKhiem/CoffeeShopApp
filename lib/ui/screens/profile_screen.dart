// lib/ui/screens/profile_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_coffee_shop_app/controllers/profile_controller.dart';
import 'package:flutter_coffee_shop_app/entities/khachhang.dart';
import 'package:flutter_coffee_shop_app/ui/screens/login_screen.dart';
import 'package:flutter_coffee_shop_app/ui/screens/purchase_history_screen.dart';
import 'package:flutter_coffee_shop_app/ui/theme/app_theme.dart';

const String kDefaultAvatar =
    'https://rubeafovywlrgxblfmlr.supabase.co/storage/v1/object/public/avatar/avatar.png';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final controller = ProfileController();
  final supabase = Supabase.instance.client;

  KhachHang? _kh;
  bool _loading = true;
  bool _saving = false;
  bool _uploadingAvatar = false;

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _avatarUrl = kDefaultAvatar;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    final data = await controller.loadCurrentCustomer(null);
    setState(() {
      _kh = data;
      _nameCtrl.text = data?.tenkh ?? '';
      _phoneCtrl.text = data?.sdt ?? '';
      _avatarUrl = data?.avatarURL ?? kDefaultAvatar;
      _loading = false;
    });
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(msg, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    final err = await controller.updateProfile(
      tenKh: _nameCtrl.text.trim(),
      sdt: _phoneCtrl.text.trim(),
    );
    setState(() => _saving = false);
    if (err == null) {
      _snack('Đã lưu thông tin thành công', Colors.green);
      _loadProfile();
    } else {
      _snack(err, Colors.red);
    }
  }

  Future<void> _changeAvatar() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      setState(() => _uploadingAvatar = true);

      final Uint8List bytes = await picked.readAsBytes();
      final mimeType = lookupMimeType(picked.name);
      final fileName =
          '${_kh?.id_khachhang ?? "guest"}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      try {
        await supabase.storage.from('avatar').uploadBinary(
              fileName,
              bytes,
              fileOptions: FileOptions(contentType: mimeType),
            );
      } on StorageException catch (e) {
        _snack('Lỗi khi tải ảnh lên: ${e.message}', Colors.red);
        setState(() => _uploadingAvatar = false);
        return;
      } catch (e) {
        _snack('Lỗi không xác định: $e', Colors.red);
        setState(() => _uploadingAvatar = false);
        return;
      }

      final publicUrl = supabase.storage.from('avatar').getPublicUrl(fileName);

      await supabase.from('khachhang').update({'AvatarURL': publicUrl}).eq(
          'id_khachhang', _kh!.id_khachhang);

      setState(() {
        _avatarUrl = publicUrl;
        _uploadingAvatar = false;
      });

      _snack('Đã cập nhật ảnh đại diện', Colors.green);
      Navigator.pop(context, true); // reload avatar ở Home
    } catch (e) {
      _snack('Lỗi đổi ảnh: $e', Colors.red);
      setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _logout() async {
    await controller.logout();
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
        body: Center(child: CircularProgressIndicator(color: Colors.brown)),
      );
    }

    return Scaffold(
      backgroundColor: Apptheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Hồ sơ khách hàng'),
        backgroundColor: Colors.brown,
        actions: [
          IconButton(onPressed: _loadProfile, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // --- ẢNH ĐẠI DIỆN ---
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
                    errorBuilder: (_, __, ___) => Image.network(
                      kDefaultAvatar,
                      width: 120,
                      height: 120,
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

            _field('Họ tên', _nameCtrl, 'Nhập họ tên'),
            const SizedBox(height: 12),
            _field('Số điện thoại', _phoneCtrl, 'Nhập số điện thoại'),
            const SizedBox(height: 12),
            _readonly('Email', _kh?.email ?? 'Chưa cập nhật'),
            _readonly('Điểm tích lũy', '${_kh?.diemtichluy ?? 0} điểm'),
            _readonly(
                'Hạng thành viên', controller.getRank(_kh?.diemtichluy ?? 0)),
            const SizedBox(height: 24),

            _button(Icons.save, _saving ? 'Đang lưu...' : 'Lưu thay đổi',
                _saving ? null : _saveProfile, Colors.brown.shade600),
            const SizedBox(height: 16),

            _button(Icons.history, 'Xem lịch sử mua hàng', () {
              if (_kh == null) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PurchaseHistoryScreen(idKhach: _kh!.id_khachhang),
                ),
              );
            }, Colors.brown.shade700),
          ],
        ),
      ),
    );
  }

  // --- Widgets phụ ---
  Widget _field(String label, TextEditingController c, String hint) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          TextField(
            controller: c,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.white.withOpacity(0.08),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      );

  Widget _readonly(String label, String value) => Column(
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
            ),
            child: Text(
              value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      );

  Widget _button(
          IconData icon, String text, VoidCallback? onPressed, Color color) =>
      SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white),
          label: Text(text, style: const TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
}
