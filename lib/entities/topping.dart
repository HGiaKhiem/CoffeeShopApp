class ToppingModel {
  final int id_topping;
  final String tentopping;
  final double giatang;

  ToppingModel({
    required this.id_topping,
    required this.tentopping,
    required this.giatang,
  });

  factory ToppingModel.fromJson(Map<String, dynamic> json) {
    return ToppingModel(
      id_topping: json['id_topping'],
      tentopping: json['tentopping'],
      giatang: (json['giatang'] is int)
          ? (json['giatang'] as int).toDouble()
          : double.parse(json['giatang'].toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id_topping': id_topping,
        'tentopping': tentopping,
        'giatang': giatang,
      };
}
