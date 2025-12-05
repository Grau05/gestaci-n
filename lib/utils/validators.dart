class Validators {
  static String? validateIdVisible(String? value) {
    if (value == null || value.isEmpty) {
      return 'El ID visible es obligatorio';
    }
    if (!RegExp(r'^\d{1,4}$').hasMatch(value)) {
      return 'ID debe ser numérico entre 1 y 4 dígitos';
    }
    return null;
  }

  static String? validateRaza(String? value) {
    if (value == null || value.isEmpty) {
      return 'La raza es obligatoria';
    }
    if (value.length < 2) {
      return 'La raza debe tener al menos 2 caracteres';
    }
    return null;
  }

  static String? validateMeses(String? value) {
    if (value == null || value.isEmpty) {
      return 'Los meses de embarazo son obligatorios';
    }
    final meses = int.tryParse(value);
    if (meses == null || meses < 0 || meses > 9) {
      return 'Los meses deben estar entre 0 y 9';
    }
    return null;
  }
}
