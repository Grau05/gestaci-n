class Note {
  final String id;
  final int idAnimal;
  final String contenido;
  final DateTime fecha;
  final String tipo; // observacion, tratamiento, sintoma

  Note({
    String? id,
    required this.idAnimal,
    required this.contenido,
    DateTime? fecha,
    this.tipo = 'observacion',
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        fecha = fecha ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_animal': idAnimal,
      'contenido': contenido,
      'fecha': fecha.toIso8601String(),
      'tipo': tipo,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      idAnimal: map['id_animal'] as int,
      contenido: map['contenido'] as String,
      fecha: DateTime.parse(map['fecha'] as String),
      tipo: map['tipo'] as String? ?? 'observacion',
    );
  }
}
