import 'package:supabase_flutter/supabase_flutter.dart';
import '../entities/ban.dart';

class BanRepository {
  final SupabaseClient _sb;
  BanRepository({SupabaseClient? client})
      : _sb = client ?? Supabase.instance.client;

  /// Lấy 1 bàn theo qr_token (uuid trong QR)
  Future<Ban?> getByToken(String token) async {
    final data = await _sb
        .from('ban')
        .select('id_ban, soban, trangthai, qr_token, loaiban')
        .eq('qr_token', token)
        .maybeSingle();
    if (data == null) return null;
    return Ban.fromMap(data);
  }

  /// Lấy 1 bàn theo id
  Future<Ban?> getById(int idBan) async {
    final data = await _sb
        .from('ban')
        .select('id_ban, soban, trangthai, qr_token, loaiban')
        .eq('id_ban', idBan)
        .maybeSingle();
    if (data == null) return null;
    return Ban.fromMap(data);
  }

  /// Danh sách tất cả bàn (sắp xếp theo số bàn)
  Future<List<Ban>> listAll() async {
    final rows = await _sb
        .from('ban')
        .select('id_ban, soban, trangthai, qr_token, loaiban')
        .order('soban', ascending: true);
    return (rows as List)
        .map((e) => Ban.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Cập nhật trạng thái bàn
  Future<void> updateTrangThai(int idBan, String trangThai) async {
    await _sb.from('ban').update({'trangthai': trangThai}).eq('id_ban', idBan);
  }
}
