class Farm {
  final int? id;
  final String nombre;
  final String? ubicacion;
  final String? encargado;
  final DateTime fechaRegistro;

  Farm({
    this.id,
    required this.nombre,
    this.ubicacion,
    this.encargado,
    DateTime? fechaRegistro,
  }) : fechaRegistro = fechaRegistro ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'ubicacion': ubicacion,
      'encargado': encargado,
      'fecha_registro': fechaRegistro.toIso8601String(),
    };
  }

  factory Farm.fromMap(Map<String, dynamic> map) {
    return Farm(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      ubicacion: map['ubicacion'] as String?,
      encargado: map['encargado'] as String?,
      fechaRegistro: map['fecha_registro'] != null
          ? DateTime.parse(map['fecha_registro'] as String)
          : DateTime.now(),
    );
  }
}
