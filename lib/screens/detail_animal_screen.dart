import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestantes/models/animal.dart';
import 'package:gestantes/models/note.dart';
import 'package:gestantes/providers/animal_provider.dart';
import 'package:gestantes/screens/add_edit_animal_screen.dart';
import 'package:gestantes/utils/gestation_calculator.dart';
import 'package:intl/intl.dart';

class DetailAnimalScreen extends StatefulWidget {
  final Animal animal;

  const DetailAnimalScreen({Key? key, required this.animal}) : super(key: key);

  @override
  State<DetailAnimalScreen> createState() => _DetailAnimalScreenState();
}

class _DetailAnimalScreenState extends State<DetailAnimalScreen> {
  late TextEditingController _noteController;
  String _noteType = 'observacion';
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    _loadNotes();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    final notes = await context
        .read<AnimalProvider>()
        .getNotesByAnimal(widget.animal.idInterno!);
    setState(() => _notes = notes);
  }

  void _deleteAnimal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar'),
        content: Text('¿Eliminar a ${widget.animal.idVisible}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<AnimalProvider>()
                  .deleteAnimal(widget.animal.idInterno!);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _addNote() {
    if (_noteController.text.isEmpty) return;

    final note = Note(
      idAnimal: widget.animal.idInterno!,
      contenido: _noteController.text,
      tipo: _noteType,
    );

    context.read<AnimalProvider>().addNote(note);
    _noteController.clear();
    setState(() => _noteType = 'observacion');
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    final riskType = GestationCalculator.classifyRisk(widget.animal);
    final riskInfo = GestationCalculator.getRiskInfo(riskType);
    final progress =
        GestationCalculator.calculateGestationProgress(widget.animal);
    final daysUntil = GestationCalculator.daysUntilDelivery(widget.animal);
    final weeks = GestationCalculator.calculateGestationWeeks(widget.animal);
    final trimester =
        GestationCalculator.calculateTrimester(widget.animal);

    return Scaffold(
      appBar: AppBar(
        title: Text('Vaca ${widget.animal.idVisible}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (_) =>
                          AddEditAnimalScreen(animal: widget.animal),
                    ),
                  )
                  .then((_) => Navigator.pop(context));
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteAnimal(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRiskCard(context, riskInfo),
            _buildInfoCard(context),
            _buildGestationCard(context, progress, weeks, trimester, daysUntil),
            _buildNotesSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskCard(
    BuildContext context,
    Map<String, dynamic> riskInfo,
  ) {
    return Card(
      color: Color(riskInfo['color']).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          spacing: 16,
          children: [
            Icon(
              Icons.warning,
              color: Color(riskInfo['color']),
              size: 32,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    riskInfo['label'],
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Color(riskInfo['color']),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    riskInfo['descripcion'],
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 12,
          children: [
            _buildDetailRow(context, 'ID Visible', widget.animal.idVisible),
            if (widget.animal.nombre != null &&
                widget.animal.nombre!.isNotEmpty)
              _buildDetailRow(context, 'Nombre', widget.animal.nombre!),
            _buildDetailRow(context, 'Raza', widget.animal.raza),
            _buildDetailRow(context, 'Estado', widget.animal.estado),
            if (widget.animal.fechaMonta != null)
              _buildDetailRow(
                context,
                'Fecha Monta',
                DateFormat('dd/MM/yyyy').format(widget.animal.fechaMonta!),
              ),
            if (widget.animal.fechaUltimoPalpado != null)
              _buildDetailRow(
                context,
                'Último Palpado',
                DateFormat('dd/MM/yyyy').format(widget.animal.fechaUltimoPalpado!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _buildGestationCard(
    BuildContext context,
    double progress,
    int weeks,
    int trimester,
    int daysUntil,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Text(
              'Gestación',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Column(
              spacing: 12,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${weeks} semanas', style: Theme.of(context).textTheme.bodyMedium),
                    Text('Trimestre $trimester', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    minHeight: 12,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                Text(
                  '${progress.toStringAsFixed(1)}% completado',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (daysUntil >= 0)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Text(
                          'Parto estimado',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          'En $daysUntil días',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Text(
          'Notas y Observaciones',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              spacing: 12,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _noteType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de nota',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'observacion', child: Text('Observación')),
                    DropdownMenuItem(value: 'tratamiento', child: Text('Tratamiento')),
                    DropdownMenuItem(value: 'sintoma', child: Text('Síntoma')),
                  ],
                  onChanged: (value) {
                    setState(() => _noteType = value ?? 'observacion');
                  },
                ),
                TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    hintText: 'Agregar nota...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  maxLines: 3,
                ),
                ElevatedButton.icon(
                  onPressed: _addNote,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar Nota'),
                ),
              ],
            ),
          ),
        ),
        if (_notes.isNotEmpty)
          Column(
            spacing: 8,
            children: _notes
                .map(
                  (note) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  note.tipo,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.blue[900],
                                      ),
                                ),
                              ),
                              Text(
                                DateFormat('dd/MM/yyyy HH:mm').format(note.fecha),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey,
                                    ),
                              ),
                            ],
                          ),
                          Text(
                            note.contenido,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(Icons.delete, size: 18),
                              onPressed: () {
                                context.read<AnimalProvider>().deleteNote(note.id);
                                _loadNotes();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}
