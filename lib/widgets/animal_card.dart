import 'package:flutter/material.dart';
import 'package:gestantes/models/animal.dart';
import 'package:gestantes/utils/gestation_calculator.dart';
import 'package:intl/intl.dart';

class AnimalCard extends StatelessWidget {
  final Animal animal;

  const AnimalCard({Key? key, required this.animal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final riskType = GestationCalculator.classifyRisk(animal);
    final riskInfo = GestationCalculator.getRiskInfo(riskType);
    final progress = GestationCalculator.calculateGestationProgress(animal);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text(
                        'ID: ${animal.idVisible}',
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      if (animal.nombre != null && animal.nombre!.isNotEmpty)
                        Text(
                          animal.nombre!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Color(riskInfo['color']).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Color(riskInfo['color']),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    riskInfo['label'],
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(riskInfo['color']),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(
                      'Raza: ${animal.raza}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '${animal.mesesEmbarazo} meses (${GestationCalculator.calculateGestationWeeks(animal)} semanas)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
                if (animal.fechaUltimoPalpado != null)
                  Text(
                    'Palpado: ${DateFormat('dd/MM').format(animal.fechaUltimoPalpado!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
              ],
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress / 100,
                minHeight: 6,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(riskInfo['color']),
                ),
              ),
            ),
            Text(
              '${progress.toStringAsFixed(1)}% de gestación',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
