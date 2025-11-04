  class Ban {
    final int idBan; // id_ban BIGSERIAL
    final int soBan; // soban INT (UNIQUE)
    final String trangThai; // trangthai VARCHAR(20)
    final String qrToken; // qr_token UUID
    final String? loaiBan; // loaiban VARCHAR (nullable)

    const Ban({
      required this.idBan,
      required this.soBan,
      required this.trangThai,
      required this.qrToken,
      this.loaiBan,
    });

    factory Ban.fromMap(Map<String, dynamic> map) {
      return Ban(
        idBan: map['id_ban'] is int
            ? map['id_ban']
            : int.parse(map['id_ban'].toString()),
        soBan: map['soban'] is int
            ? map['soban']
            : int.parse(map['soban'].toString()),
        trangThai: map['trangthai']?.toString() ?? 'Trống',
        qrToken: map['qr_token']?.toString() ?? '',
        loaiBan: map['loaiban']?.toString(),
      );
    }

    Map<String, dynamic> toMap() => {
          'id_ban': idBan,
          'soban': soBan,
          'trangthai': trangThai,
          'qr_token': qrToken,
          'loaiban': loaiBan,
        };

    Ban copyWith({
      int? idBan,
      int? soBan,
      String? trangThai,
      String? qrToken,
      String? loaiBan,
    }) {
      return Ban(
        idBan: idBan ?? this.idBan,
        soBan: soBan ?? this.soBan,
        trangThai: trangThai ?? this.trangThai,
        qrToken: qrToken ?? this.qrToken,
        loaiBan: loaiBan ?? this.loaiBan,
      );
    }
  }
