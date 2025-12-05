import 'package:flutter/material.dart';
import 'package:gestantes/models/animal.dart';
import 'package:gestantes/models/note.dart';
import 'package:gestantes/providers/animal_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AnimalHistoryScreen extends StatefulWidget {
  final Animal animal;

  const AnimalHistoryScreen({Key? key, required this.animal}) : super(key: key);

  @override
  State<AnimalHistoryScreen> createState() => _AnimalHistoryScreenState();
}

class _AnimalHistoryScreenState extends State<AnimalHistoryScreen> {
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await context
        .read<AnimalProvider>()
        .getNotesByAnimal(widget.animal.idInterno!);
    setState(() => _notes = notes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial - Vaca ${widget.animal.idVisible}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 16,
          children: [
            _buildTimelineHeader(context),
            if (_notes.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('Sin historial registrado'),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  final note = _notes[index];
                  final isLast = index == _notes.length - 1;

                  return Column(
                    children: [
                      _buildTimelineItem(context, note, index, isLast),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineHeader(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 8,
          children: [
            Text(
              'Historial Completo',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              '${_notes.length} eventos registrados',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, Note note, int index, bool isLast) {
    final typeColor = _getNoteTypeColor(note.tipo);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: typeColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getNoteTypeIcon(note.tipo),
                color: Colors.white,
                size: 20,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: Colors.grey[300],
              ),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            note.tipo,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: typeColor,
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getNoteTypeColor(String tipo) {
    switch (tipo) {
      case 'observacion':
        return Colors.blue;
      case 'tratamiento':
        return Colors.orange;
      case 'sintoma':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getNoteTypeIcon(String tipo) {
    switch (tipo) {
      case 'observacion':
        return Icons.visibility;
      case 'tratamiento':
        return Icons.medical_services;
      case 'sintoma':
        return Icons.warning;
      default:
        return Icons.note;
    }
  }
}
