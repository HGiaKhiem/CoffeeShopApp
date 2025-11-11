import 'package:supabase_flutter/supabase_flutter.dart';

class PurchaseHistoryController {
  final supabase = Supabase.instance.client;

  /// 🔹 Lấy danh sách lịch sử mua hàng (JOIN sang danhgia_mon)
  Future<List<Map<String, dynamic>>> loadHistory(int idKhach) async {
    try {
      final response = await supabase.from('lichsumuahang').select('''
            id_lichsu,
            id_khachhang,
            id_mon,
            id_donhang,
            soluong,
            giaban,
            ngaymua,
            mon:lichsumuahang_id_mon_fkey(tenmon, "HinhAnh", gia),
            donhang:lichsumuahang_id_donhang_fkey(trangthai),
            danhgia_mon(sosao, nhanxet, ngaydanhgia)
          ''').eq('id_khachhang', idKhach).order('ngaymua', ascending: false);

      print('✅ Dữ liệu lịch sử: $response');
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      print('❌ Lỗi load lịch sử: ${e.message}');
      return [];
    } catch (e) {
      print('❌ Lỗi không xác định: $e');
      return [];
    }
  }

  /// 🔹 Gửi hoặc cập nhật đánh giá món
  Future<bool> sendFeedback({
    required int idLichSu,
    required int idKhachHang,
    required int idMon,
    required int rating,
    required String comment,
  }) async {
    try {
      // Kiểm tra xem đã có đánh giá chưa
      final existing = await supabase
          .from('danhgia_mon')
          .select('id_danhgia')
          .eq('id_lichsu', idLichSu)
          .maybeSingle();

      if (existing == null) {
        // ✅ Thêm mới
        await supabase.from('danhgia_mon').insert({
          'id_lichsu': idLichSu,
          'id_khachhang': idKhachHang,
          'id_mon': idMon,
          'sosao': rating,
          'nhanxet': comment,
        });
      } else {
        // 🔄 Cập nhật
        await supabase.from('danhgia_mon').update({
          'sosao': rating,
          'nhanxet': comment,
          'ngaydanhgia': DateTime.now().toIso8601String(),
        }).eq('id_danhgia', existing['id_danhgia']);
      }

      return true;
    } on PostgrestException catch (e) {
      print('❌ Lỗi gửi đánh giá: ${e.message}');
      return false;
    } catch (e) {
      print('❌ Lỗi không xác định khi gửi đánh giá: $e');
      return false;
    }
  }
}
