import 'package:flutter_coffee_shop_app/entities/coffee.dart';

/// Model tạm đại diện cho 1 món trong giỏ hàng (chưa lưu DB)
class CartItem {
  final Coffee mon; // Món được chọn
  int soLuong;
  double giaBan; // Giá bán sau khi cộng topping + size
  Map<String, dynamic> tuyChon; // size, topping, ghi chú,...

  CartItem({
    required this.mon,
    required this.soLuong,
    required this.giaBan,
    required this.tuyChon,
  });

  /// Tổng tiền của món này
  double get thanhTien => giaBan * soLuong;

  /// Chuyển sang JSON (dùng khi insert DB)
  Map<String, dynamic> toJson(int idDonHang) {
    return {
      'id_donhang': idDonHang,
      'id_mon': mon.id_mon, // ✅ sửa lại cho khớp Coffee
      'soluong': soLuong,
      'giaban': giaBan,
      'tuychon_json': tuyChon,
    };
  }

  /// Tạo từ JSON (nếu cần hiển thị lại)
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      mon: Coffee.fromJson(json['mon']),
      soLuong: json['soluong'],
      giaBan: (json['giaban'] as num).toDouble(),
      tuyChon: json['tuychon_json'] ?? {},
    );
  }
}
