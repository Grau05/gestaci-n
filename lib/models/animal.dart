class Animal {
  final int? idInterno;
  final String idVisible;
  final String? nombre;
  final String raza;
  final int mesesEmbarazo;
  final DateTime? fechaUltimoPalpado;
  final DateTime? fechaMonta;
  final String estado; // preñada, vacía, dudosa, parida
  final int idFinca;
  final List<String> etiquetas;
  final DateTime fechaRegistro;

  Animal({
    this.idInterno,
    required this.idVisible,
    this.nombre,
    required this.raza,
    required this.mesesEmbarazo,
    this.fechaUltimoPalpado,
    this.fechaMonta,
    this.estado = 'preñada',
    this.idFinca = 1,
    this.etiquetas = const [],
    DateTime? fechaRegistro,
  }) : fechaRegistro = fechaRegistro ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id_interno': idInterno,
      'id_visible': idVisible,
      'nombre': nombre,
      'raza': raza,
      'meses_embarazo': mesesEmbarazo,
      'fecha_ultimo_palpado': fechaUltimoPalpado?.toIso8601String(),
      'fecha_monta': fechaMonta?.toIso8601String(),
      'estado': estado,
      'id_finca': idFinca,
      'etiquetas': etiquetas.join(','),
      'fecha_registro': fechaRegistro.toIso8601String(),
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
      fechaMonta: map['fecha_monta'] != null
          ? DateTime.parse(map['fecha_monta'] as String)
          : null,
      estado: map['estado'] as String? ?? 'preñada',
      idFinca: map['id_finca'] as int? ?? 1,
      etiquetas: (map['etiquetas'] as String?)
              ?.split(',')
              .where((e) => e.isNotEmpty)
              .toList() ??
          [],
      fechaRegistro: map['fecha_registro'] != null
          ? DateTime.parse(map['fecha_registro'] as String)
          : DateTime.now(),
    );
  }

  Animal copyWith({
    int? idInterno,
    String? idVisible,
    String? nombre,
    String? raza,
    int? mesesEmbarazo,
    DateTime? fechaUltimoPalpado,
    DateTime? fechaMonta,
    String? estado,
    int? idFinca,
    List<String>? etiquetas,
    DateTime? fechaRegistro,
  }) {
    return Animal(
      idInterno: idInterno ?? this.idInterno,
      idVisible: idVisible ?? this.idVisible,
      nombre: nombre ?? this.nombre,
      raza: raza ?? this.raza,
      mesesEmbarazo: mesesEmbarazo ?? this.mesesEmbarazo,
      fechaUltimoPalpado: fechaUltimoPalpado ?? this.fechaUltimoPalpado,
      fechaMonta: fechaMonta ?? this.fechaMonta,
      estado: estado ?? this.estado,
      idFinca: idFinca ?? this.idFinca,
      etiquetas: etiquetas ?? this.etiquetas,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }
}
