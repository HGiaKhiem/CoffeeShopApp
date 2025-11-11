import 'package:supabase_flutter/supabase_flutter.dart';
import '../entities/entities_library.dart';

class HomeController {
  static final supabase = Supabase.instance.client;

  /// 🟩 Lấy danh sách món (Coffee)
  static Future<List<Coffee>> getAllCoffees() async {
    try {
      final response = await supabase.from('mon').select('*');
      print('✅ [Supabase] Dữ liệu món: $response');

      return (response as List).map((json) => Coffee.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      print('❌ Lỗi Supabase khi fetch coffee: ${e.message}');
      return [];
    } catch (e) {
      print('⚠️ Lỗi khác khi fetch coffee: $e');
      return [];
    }
  }

  /// 🟩 Lấy danh sách loại món
  static Future<List<LoaiMon>> getAllLoaiMon() async {
    try {
      final response = await supabase.from('loaimon').select('*');
      print('✅ [Supabase] Dữ liệu loại món: $response');

      return (response as List).map((json) => LoaiMon.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      print('❌ Lỗi Supabase khi fetch loại món: ${e.message}');
      return [];
    } catch (e) {
      print('⚠️ Lỗi khác khi fetch loại món: $e');
      return [];
    }
  }

  /// 🟩 Lấy danh sách introduction
  static Future<List<Introduction>> getAllIntroductions() async {
    try {
      final response = await supabase.from('introductions').select('*');
      print('✅ [Supabase] Dữ liệu introduction: $response');

      return (response as List)
          .map((json) => Introduction.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      print('❌ Lỗi Supabase khi fetch introduction: ${e.message}');
      return [];
    } catch (e) {
      print('⚠️ Lỗi khác khi fetch introduction: $e');
      return [];
    }
  }

  /// 🟩 Lấy danh sách size
  static Future<List<Size>> getAllSizes() async {
    try {
      final response = await supabase.from('size').select('*');
      print('✅ [Supabase] Dữ liệu size: $response');

      return (response as List).map((json) => Size.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      print('❌ Lỗi Supabase khi fetch size: ${e.message}');
      return [];
    } catch (e) {
      print('⚠️ Lỗi khác khi fetch size: $e');
      return [];
    }
  }

  static Future<KhachHang?> getCurrentCustomer() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final user = supabase.auth.currentUser;
    if (user == null) {
      print('⚠️ Chưa có session Supabase → user = null');
      return null;
    }

    try {
      final response = await supabase
          .from('khachhang')
          .select('*')
          .eq('UID', user.id)
          .maybeSingle();

      if (response != null) {
        print('✅ Dữ liệu khách hàng: $response');
        return KhachHang.fromJson(response);
      } else {
        print('⚠️ Không tìm thấy khách hàng cho UID: ${user.id}');
        return null;
      }
    } catch (e) {
      print('❌ Lỗi khi fetch khách hàng: $e');
      return null;
    }
  }

  /// 🔍 Tìm kiếm theo tên món
  static List<Coffee> searchCoffees(List<Coffee> coffees, String query) {
    if (query.isEmpty) return coffees;
    final lowerQuery = query.toLowerCase();
    return coffees
        .where((c) => c.tenmon.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// 💎 Lấy danh sách món đặc biệt (giá cao hơn trung bình)
  static List<Coffee> getSpecialCoffees(List<Coffee> coffees) {
    if (coffees.isEmpty) return [];
    final avgPrice =
        coffees.map((c) => c.gia).reduce((a, b) => a + b) / coffees.length;
    return coffees.where((c) => c.gia > avgPrice).toList();
  }

  /// ☕ Lọc món theo loại (category)
  static List<Coffee> filterByCategory(List<Coffee> coffees, int categoryId) {
    return coffees.where((c) => c.id_loaimon == categoryId).toList();
  }

  static Future<List<Map<String, dynamic>>> getRecentReviews(int idMon) async {
    try {
      final response = await supabase
          .from('danhgia_mon')
          .select('''
            sosao,
            nhanxet,
            ngaydanhgia,
            khachhang(id_khachhang, tenkh, "AvatarURL")
          ''')
          .eq('id_mon', idMon)
          .order('ngaydanhgia', ascending: false)
          .limit(3); // chỉ lấy 3 đánh giá mới nhất

      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      print('❌ Lỗi load đánh giá: ${e.message}');
      return [];
    } catch (e) {
      print('❌ Lỗi không xác định: $e');
      return [];
    }
  }
}
