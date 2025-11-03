class Size {
  final int id_size;
  final String tensize;
  final double giatang;

  Size({
    required this.id_size,
    required this.tensize,
    required this.giatang,
  });

  factory Size.fromJson(Map<String, dynamic> json) {
    return Size(
      id_size: json['id_size'] ?? json['ID_Size'],
      tensize: json['tensize'] ?? json['TenSize'],
      giatang: json['giatang'] is int
          ? (json['giatang'] as int).toDouble()
          : double.parse(json['giatang'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_size': id_size,
      'tensize': tensize,
      'giatang': giatang,
    };
  }
}
