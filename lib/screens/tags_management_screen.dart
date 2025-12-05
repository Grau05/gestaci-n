import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestantes/models/animal.dart';
import 'package:gestantes/providers/animal_provider.dart';

class TagsManagementScreen extends StatefulWidget {
  final Animal animal;

  const TagsManagementScreen({super.key, required this.animal});

  @override
  State<TagsManagementScreen> createState() => _TagsManagementScreenState();
}

class _TagsManagementScreenState extends State<TagsManagementScreen> {
  late List<String> _selectedTags;
  late TextEditingController _newTagController;

  final List<String> _predefinedTags = [
    'Problema sanitario',
    'Venta',
    'Reproductor',
    'Seguimiento',
    'Urgente',
    'Vacunada',
    'Medicada',
    'Cuarentena',
  ];

  @override
  void initState() {
    super.initState();
    _selectedTags = List.from(widget.animal.etiquetas);
    _newTagController = TextEditingController();
  }

  @override
  void dispose() {
    _newTagController.dispose();
    super.dispose();
  }

  void _saveTags() {
    final updatedAnimal = widget.animal.copyWith(etiquetas: _selectedTags);
    context.read<AnimalProvider>().updateAnimal(updatedAnimal);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Etiquetas actualizadas')),
    );
    Navigator.pop(context);
  }

  void _addCustomTag() {
    if (_newTagController.text.isNotEmpty) {
      setState(() {
        _selectedTags.add(_newTagController.text.trim());
        _newTagController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Etiquetas'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 20,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    Text(
                      'Agregar Etiqueta Personalizada',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Row(
                      spacing: 8,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _newTagController,
                            decoration: InputDecoration(
                              hintText: 'Nueva etiqueta',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _addCustomTag,
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_selectedTags.isNotEmpty)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [
                      Text(
                        'Etiquetas Seleccionadas',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedTags
                            .map((tag) => Chip(
                          label: Text(tag),
                          onDeleted: () {
                            setState(() => _selectedTags.remove(tag));
                          },
                          backgroundColor: Colors.blue[100],
                        ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    Text(
                      'Etiquetas Predefinidas',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _predefinedTags
                          .map((tag) => FilterChip(
                        label: Text(tag),
                        selected: _selectedTags.contains(tag),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedTags.add(tag);
                            } else {
                              _selectedTags.remove(tag);
                            }
                          });
                        },
                      ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _saveTags,
              icon: const Icon(Icons.save),
              label: const Text('Guardar Etiquetas'),
            ),
          ],
        ),
      ),
    );
  }
}
