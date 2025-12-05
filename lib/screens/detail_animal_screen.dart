import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestantes/models/animal.dart';
import 'package:gestantes/providers/animal_provider.dart';
import 'package:gestantes/screens/add_edit_animal_screen.dart';
import 'package:intl/intl.dart';

class DetailAnimalScreen extends StatelessWidget {
  final Animal animal;

  const DetailAnimalScreen({Key? key, required this.animal}) : super(key: key);

  void _deleteAnimal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar'),
        content: Text('¿Eliminar a ${animal.idVisible}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<AnimalProvider>().deleteAnimal(animal.idInterno!);
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Animal eliminado')),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vaca ${animal.idVisible}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddEditAnimalScreen(animal: animal),
                ),
              ).then((_) => Navigator.pop(context));
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteAnimal(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          spacing: 16,
          children: [
            _buildDetailCard(context, 'ID Visible', animal.idVisible),
            _buildDetailCard(context, 'Nombre', animal.nombre ?? 'No especificado'),
            _buildDetailCard(context, 'Raza', animal.raza),
            _buildDetailCard(context, 'Meses de Embarazo', '${animal.mesesEmbarazo} meses'),
            _buildDetailCard(
              context,
              'Último Palpado',
              animal.fechaUltimoPalpado != null
                  ? DateFormat('dd/MM/yyyy').format(animal.fechaUltimoPalpado!)
                  : 'Sin registro',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
