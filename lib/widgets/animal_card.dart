import 'package:flutter/material.dart';
import 'package:gestantes/models/animal.dart';
import 'package:intl/intl.dart';

class AnimalCard extends StatelessWidget {
  final Animal animal;

  const AnimalCard({Key? key, required this.animal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID: ${animal.idVisible}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${animal.mesesEmbarazo} meses',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[900],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (animal.nombre != null && animal.nombre!.isNotEmpty)
              Text(
                animal.nombre!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Raza: ${animal.raza}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (animal.fechaUltimoPalpado != null)
                  Text(
                    'Palpado: ${DateFormat('dd/MM/yy').format(animal.fechaUltimoPalpado!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
