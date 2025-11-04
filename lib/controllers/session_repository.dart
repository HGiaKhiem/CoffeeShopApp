// lib/controllers/session_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SessionRepository {
  final SupabaseClient _sb;
  SessionRepository({SupabaseClient? client})
      : _sb = client ?? Supabase.instance.client;

  /// Gắn phiên (nếu có dùng bảng session_ban)
  Future<void> attachCustomer(String sessionId, int idKh) async {
    await _sb
        .from('session_ban')
        .update({'id_khachhang': idKh})
        .eq('session_id', sessionId);
  }
}

final sessionRepo = SessionRepository();
