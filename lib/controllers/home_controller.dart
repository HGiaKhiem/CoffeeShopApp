import 'package:flutter_coffee_shop_app/entities/topping.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../entities/entities_library.dart';

class HomeController {
  static final supabase = Supabase.instance.client;

  /// Hàm chờ auth ready
  static Future<void> waitForAuthReady() async {
    int retry = 0;
    while (supabase.auth.currentSession == null && retry < 10) {
      await Future.delayed(const Duration(milliseconds: 150));
      retry++;
    }
  }

  /// Lấy danh sách món
  static Future<List<Coffee>> getAllCoffees() async {
    await waitForAuthReady();

    try {
      final response = await supabase
          .from('mon')
          .select('*')
          .eq('trangthai', true); // chỉ lấy món đang bán

      return (response as List).map((json) => Coffee.fromJson(json)).toList();
    } catch (e) {
      print("Lỗi load mon: $e");
      return [];
    }
  }

  /// Danh sách loại món
  static Future<List<LoaiMon>> getAllLoaiMon() async {
    await waitForAuthReady();

    try {
      final response = await supabase.from('loaimon').select('*');

      if (response is List && response.isNotEmpty) {
        print("[Supabase] loaimon: ${response.length} loại");
        return response.map((json) => LoaiMon.fromJson(json)).toList();
      }

      print("[Supabase] loaimon rỗng");
      return [];
    } catch (e) {
      print("Lỗi load loaimon: $e");
      return [];
    }
  }

  /// Lấy introduction
  static Future<List<Introduction>> getAllIntroductions() async {
    await waitForAuthReady();

    try {
      final response = await supabase.from('introductions').select('*');

      if (response is List) {
        return response.map((e) => Introduction.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      print("Lỗi load introductions: $e");
      return [];
    }
  }

  ///  Lấy size
  static Future<List<Size>> getAllSizes() async {
    await waitForAuthReady();

    try {
      final response = await supabase.from('size').select('*');

      if (response is List) {
        return response.map((e) => Size.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print("Lỗi load size: $e");
      return [];
    }
  }

  ///  Lấy danh sách topping
  static Future<List<ToppingModel>> getAllToppings() async {
    await waitForAuthReady();

    try {
      final response = await supabase
          .from('topping')
          .select('*')
          .eq('trangthai', true); // chỉ lấy topping còn bán

      return (response as List).map((e) => ToppingModel.fromJson(e)).toList();
    } catch (e) {
      print("Lỗi load topping: $e");
      return [];
    }
  }

  /// Lấy thông tin khách hàng hiện tại
  static Future<KhachHang?> getCurrentCustomer() async {
    await waitForAuthReady();

    final user = supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await supabase
          .from('khachhang')
          .select('*')
          .eq('UID', user.id)
          .maybeSingle();

      if (response != null) {
        print("Khách: ${response['tenkh']}");
        return KhachHang.fromJson(response);
      }
      return null;
    } catch (e) {
      print("Lỗi load khách: $e");
      return null;
    }
  }

  ///  Tìm kiếm
  static List<Coffee> searchCoffees(List<Coffee> coffees, String query) {
    final q = query.toLowerCase();
    return coffees.where((c) => c.tenmon.toLowerCase().contains(q)).toList();
  }

  static List<Coffee> getSpecialCoffees(List<Coffee> coffees) {
    if (coffees.isEmpty) return [];
    final avg =
        coffees.map((c) => c.gia).reduce((a, b) => a + b) / coffees.length;
    return coffees.where((c) => c.gia > avg).toList();
  }

  static List<Coffee> filterByCategory(List<Coffee> list, int id) {
    return list.where((c) => c.id_loaimon == id).toList();
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
          .limit(3);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Lỗi load đánh giá: $e");
      return [];
    }
  }

  static Future<List<Coffee>> getTopLikedDrinks() async {
    try {
      final response = await supabase.from('view_top_like').select('id_mon');

      print("TOP LIKE IDS: $response");

      final List<int> ids =
          (response as List).map<int>((e) => e['id_mon'] as int).toList();

      if (ids.isEmpty) return [];

      final monData = await supabase
          .from('mon')
          .select('*')
          .inFilter('id_mon', ids)
          .eq('trangthai', true);

      print("FULL MONS: $monData");

      return (monData as List).map((json) => Coffee.fromJson(json)).toList();
    } catch (e) {
      print("Lỗi load top like: $e");
      return [];
    }
  }
}
