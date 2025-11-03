class Coffee {
  final int id_mon;
  final String tenmon;
  final int id_loaimon;
  final double gia;
  final String? mota;
  final bool trangthai;
  final String hinhanh;

  Coffee({
    required this.id_mon,
    required this.tenmon,
    required this.id_loaimon,
    required this.gia,
    this.mota,
    required this.trangthai,
    required this.hinhanh,
  });

  factory Coffee.fromJson(Map<String, dynamic> json) {
    return Coffee(
      id_mon: json['id_mon'] ?? 0,
      tenmon: json['tenmon'] ?? '',
      id_loaimon: json['id_loaimon'] ?? 0,
      gia: json['gia'] is num
          ? (json['gia'] as num).toDouble()
          : double.tryParse(json['gia'].toString()) ?? 0.0,
      mota: json['mota'] as String?,
      trangthai: json['trangthai'] ?? true,
      hinhanh: json['HinhAnh'] as String,
    );
  }
}
