import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class VoucherController {
  /// Lấy điểm tích lũy của khách hàng
  static Future<int> getDiemTichLuy(int idKhach) async {
    try {
      final data = await supabase
          .from('khachhang')
          .select('diemtichluy')
          .eq('id_khachhang', idKhach)
          .maybeSingle();

      return (data?['diemtichluy'] as num?)?.toInt() ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Lấy danh sách voucher (từ bảng voucher)
  static Future<List<Map<String, dynamic>>> getVoucherList() async {
    try {
      final data = await supabase
          .from('voucher')
          .select(
              'id_voucher, ten_voucher, phantram_giam, diem_doi, ngayhethan')
          .eq('trangthai', true)
          .order('diem_doi', ascending: true);

      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }

  /// Lấy voucher KH đang sở hữu
  static Future<List<Map<String, dynamic>>> getVoucherDaDoi(int idKhach) async {
    try {
      final data = await supabase
          .from('khachhang_voucher')
          .select('id_khv, trangthai, ngaydoi, voucher(*)')
          .eq('id_khachhang', idKhach)
          .order('ngaydoi', ascending: false);

      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }

  /// Gọi RPC đổi điểm lấy voucher
  static Future<String> doiVoucher(int idKhach, int idVoucher) async {
    try {
      final result = await supabase.rpc(
        'doi_diem_sang_voucher',
        params: {
          'p_id_khach': idKhach,
          'p_id_voucher': idVoucher,
        },
      );

      return result.toString();
    } catch (e) {
      return "Lỗi khi đổi voucher: $e";
    }
  }
}
