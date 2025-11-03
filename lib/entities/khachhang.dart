class KhachHang {
  final int id_khachhang;
  final String tenkh;
  final String? sdt;
  final String? email;
  final int diemtichluy;
  final String? hangthanhvien;
  final String? avatarURL;

  KhachHang({
    required this.id_khachhang,
    required this.tenkh,
    this.sdt,
    this.email,
    required this.diemtichluy,
    required this.hangthanhvien,
    this.avatarURL,
  });

  factory KhachHang.fromJson(Map<String, dynamic> json) {
    return KhachHang(
      id_khachhang: json['id_khachhang'],
      tenkh: json['tenkh'],
      sdt: json['sdt'],
      email: json['email'],
      diemtichluy: json['diemtichluy'] ?? 0,
      hangthanhvien: json['hangthanhvien'],
      avatarURL: json['AvatarURL'],
    );
  }
}
