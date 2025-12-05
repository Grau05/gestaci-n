import 'package:gestantes/models/animal.dart';

class GestationCalculator {
  static const int gestationDays = 282;
  static const int maxDaysBetweenPalpados = 60;

  static DateTime? calculateEstimatedDelivery(Animal animal) {
    if (animal.fechaMonta != null) {
      return animal.fechaMonta!.add(Duration(days: gestationDays));
    }
    if (animal.mesesEmbarazo >= 1) {
      final now = DateTime.now();
      final estimatedMonta =
          now.subtract(Duration(days: animal.mesesEmbarazo * 30));
      return estimatedMonta.add(Duration(days: gestationDays));
    }
    return null;
  }

  static int calculateGestationDays(Animal animal) {
    if (animal.fechaMonta != null) {
      return DateTime.now().difference(animal.fechaMonta!).inDays;
    }
    return animal.mesesEmbarazo * 30;
  }

  static int calculateGestationWeeks(Animal animal) {
    return calculateGestationDays(animal) ~/ 7;
  }

  static int calculateTrimester(Animal animal) {
    final weeks = calculateGestationWeeks(animal);
    if (weeks <= 13) return 1;
    if (weeks <= 26) return 2;
    return 3;
  }

  static double calculateGestationProgress(Animal animal) {
    final days = calculateGestationDays(animal);
    return (days / gestationDays * 100).clamp(0, 100);
  }

  static String classifyRisk(Animal animal) {
    final gestDays = calculateGestationDays(animal);
    final now = DateTime.now();
    final daysSincePalpado = animal.fechaUltimoPalpado != null
        ? now.difference(animal.fechaUltimoPalpado!).inDays
        : null;

    if (gestDays >= gestationDays - 14) {
      return 'riesgo_alto';
    }

    if (daysSincePalpado != null && daysSincePalpado > maxDaysBetweenPalpados) {
      return 'palpado_vencido';
    }

    if (daysSincePalpado != null && daysSincePalpado > 28) {
      return 'sin_palpado_reciente';
    }

    if (animal.mesesEmbarazo > 9) {
      return 'datos_incoherentes';
    }

    return 'normal';
  }

  static Map<String, dynamic> getRiskInfo(String riskType) {
    switch (riskType) {
      case 'riesgo_alto':
        return {
          'label': 'Alto Riesgo',
          'color': 0xFFD32F2F,
          'icon': 'warning',
          'descripcion': 'Muy próxima al parto'
        };
      case 'palpado_vencido':
        return {
          'label': 'Palpado Vencido',
          'color': 0xFFF57C00,
          'icon': 'schedule',
          'descripcion': 'Requiere palpado urgente'
        };
      case 'sin_palpado_reciente':
        return {
          'label': 'Sin Palpado Reciente',
          'color': 0xFFFBC02D,
          'icon': 'access_time',
          'descripcion': 'Hace >4 semanas'
        };
      case 'datos_incoherentes':
        return {
          'label': 'Datos Incoherentes',
          'color': 0xFF7B1FA2,
          'icon': 'error',
          'descripcion': 'Revisar información'
        };
      default:
        return {
          'label': 'Normal',
          'color': 0xFF388E3C,
          'icon': 'check_circle',
          'descripcion': 'Estado normal'
        };
    }
  }

  static DateTime? nextRecommendedPalpado(Animal animal) {
    if (animal.fechaUltimoPalpado == null) {
      return DateTime.now();
    }
    return animal.fechaUltimoPalpado!.add(const Duration(days: 28));
  }

  static int daysUntilDelivery(Animal animal) {
    final estimated = calculateEstimatedDelivery(animal);
    if (estimated == null) return -1;
    return estimated.difference(DateTime.now()).inDays;
  }
}
