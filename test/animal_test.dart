import 'package:flutter_test/flutter_test.dart';
import 'package:gestantes/models/animal.dart';

void main() {
  group('Animal Model', () {
    test('debe convertir Animal a Map correctamente', () {
      final animal = Animal(
        idInterno: 1,
        idVisible: '123',
        nombre: 'Lucero',
        raza: 'Holstein',
        mesesEmbarazo: 6,
        fechaUltimoPalpado: DateTime(2024, 1, 15),
      );

      final map = animal.toMap();
      expect(map['id_visible'], '123');
      expect(map['raza'], 'Holstein');
      expect(map['meses_embarazo'], 6);
    });

    test('debe crear Animal desde Map', () {
      final map = {
        'id_interno': 1,
        'id_visible': '123',
        'nombre': 'Lucero',
        'raza': 'Holstein',
        'meses_embarazo': 6,
        'fecha_ultimo_palpado': '2024-01-15T00:00:00.000',
      };

      final animal = Animal.fromMap(map);
      expect(animal.idVisible, '123');
      expect(animal.nombre, 'Lucero');
      expect(animal.mesesEmbarazo, 6);
    });

    test('copyWith debe crear una copia modificada', () {
      final animal = Animal(
        idInterno: 1,
        idVisible: '123',
        raza: 'Holstein',
        mesesEmbarazo: 6,
      );

      final updated = animal.copyWith(mesesEmbarazo: 7);
      expect(updated.mesesEmbarazo, 7);
      expect(updated.idVisible, '123');
    });
  });
}
