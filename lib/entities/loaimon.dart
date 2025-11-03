class LoaiMon {
  final int id_loaimon;
  final String tenloaimon;

  LoaiMon({
    required this.id_loaimon,
    required this.tenloaimon,
  });

  factory LoaiMon.fromJson(Map<String, dynamic> json) {
    return LoaiMon(
      id_loaimon: json['id_loaimon'] is int
          ? json['id_loaimon']
          : int.parse(json['id_loaimon'].toString()),
      tenloaimon: json['tenloaimon'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_loaimon': id_loaimon,
      'tenloaimon': tenloaimon,
    };
  }
}
