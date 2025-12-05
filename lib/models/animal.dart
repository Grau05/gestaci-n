class Animal {
  final int? idInterno;
  final String idVisible;
  final String? nombre;
  final String raza;
  final int mesesEmbarazo;
  final DateTime? fechaUltimoPalpado;

  Animal({
    this.idInterno,
    required this.idVisible,
    this.nombre,
    required this.raza,
    required this.mesesEmbarazo,
    this.fechaUltimoPalpado,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_interno': idInterno,
      'id_visible': idVisible,
      'nombre': nombre,
      'raza': raza,
      'meses_embarazo': mesesEmbarazo,
      'fecha_ultimo_palpado': fechaUltimoPalpado?.toIso8601String(),
    };
  }

  factory Animal.fromMap(Map<String, dynamic> map) {
    return Animal(
      idInterno: map['id_interno'] as int?,
      idVisible: map['id_visible'] as String,
      nombre: map['nombre'] as String?,
      raza: map['raza'] as String,
      mesesEmbarazo: map['meses_embarazo'] as int,
      fechaUltimoPalpado: map['fecha_ultimo_palpado'] != null
          ? DateTime.parse(map['fecha_ultimo_palpado'] as String)
          : null,
    );
  }

  Animal copyWith({
    int? idInterno,
    String? idVisible,
    String? nombre,
    String? raza,
    int? mesesEmbarazo,
    DateTime? fechaUltimoPalpado,
  }) {
    return Animal(
      idInterno: idInterno ?? this.idInterno,
      idVisible: idVisible ?? this.idVisible,
      nombre: nombre ?? this.nombre,
      raza: raza ?? this.raza,
      mesesEmbarazo: mesesEmbarazo ?? this.mesesEmbarazo,
      fechaUltimoPalpado: fechaUltimoPalpado ?? this.fechaUltimoPalpado,
    );
  }
}
