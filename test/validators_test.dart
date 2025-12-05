import 'package:flutter_test/flutter_test.dart';
import 'package:gestantes/utils/validators.dart';

void main() {
  group('Validators', () {
    group('validateIdVisible', () {
      test('debe retornar null para ID válido de 1 dígito', () {
        expect(Validators.validateIdVisible('7'), isNull);
      });

      test('debe retornar null para ID válido de 4 dígitos', () {
        expect(Validators.validateIdVisible('0423'), isNull);
      });

      test('debe retornar error para ID vacío', () {
        expect(Validators.validateIdVisible(''), isNotNull);
      });

      test('debe retornar error para ID con más de 4 dígitos', () {
        expect(Validators.validateIdVisible('12345'), isNotNull);
      });

      test('debe retornar error para ID no numérico', () {
        expect(Validators.validateIdVisible('ABC'), isNotNull);
      });
    });

    group('validateRaza', () {
      test('debe retornar null para raza válida', () {
        expect(Validators.validateRaza('Holstein'), isNull);
      });

      test('debe retornar error para raza vacía', () {
        expect(Validators.validateRaza(''), isNotNull);
      });

      test('debe retornar error para raza con 1 carácter', () {
        expect(Validators.validateRaza('H'), isNotNull);
      });
    });

    group('validateMeses', () {
      test('debe retornar null para meses válidos', () {
        expect(Validators.validateMeses('6'), isNull);
      });

      test('debe retornar error para meses mayor a 9', () {
        expect(Validators.validateMeses('10'), isNotNull);
      });

      test('debe retornar error para meses vacío', () {
        expect(Validators.validateMeses(''), isNotNull);
      });
    });
  });
}
