import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestantes/models/animal.dart';
import 'package:gestantes/providers/animal_provider.dart';
import 'package:gestantes/utils/validators.dart';
import 'package:intl/intl.dart';

class AddEditAnimalScreen extends StatefulWidget {
  final Animal? animal;

  const AddEditAnimalScreen({Key? key, this.animal}) : super(key: key);

  @override
  State<AddEditAnimalScreen> createState() => _AddEditAnimalScreenState();
}

class _AddEditAnimalScreenState extends State<AddEditAnimalScreen> {
  late TextEditingController _idVisibleController;
  late TextEditingController _nombreController;
  late TextEditingController _razaController;
  late TextEditingController _mesesController;
  DateTime? _fechaPalpado;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _idVisibleController = TextEditingController(text: widget.animal?.idVisible ?? '');
    _nombreController = TextEditingController(text: widget.animal?.nombre ?? '');
    _razaController = TextEditingController(text: widget.animal?.raza ?? '');
    _mesesController = TextEditingController(text: widget.animal?.mesesEmbarazo.toString() ?? '');
    _fechaPalpado = widget.animal?.fechaUltimoPalpado;
  }

  @override
  void dispose() {
    _idVisibleController.dispose();
    _nombreController.dispose();
    _razaController.dispose();
    _mesesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaPalpado ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _fechaPalpado) {
      setState(() {
        _fechaPalpado = picked;
      });
    }
  }

  void _saveAnimal() async {
    if (!_formKey.currentState!.validate()) return;

    final isEditing = widget.animal != null;
    final animal = Animal(
      idInterno: widget.animal?.idInterno,
      idVisible: _idVisibleController.text.trim(),
      nombre: _nombreController.text.trim().isEmpty ? null : _nombreController.text.trim(),
      raza: _razaController.text.trim(),
      mesesEmbarazo: int.parse(_mesesController.text),
      fechaUltimoPalpado: _fechaPalpado,
    );

    final provider = context.read<AnimalProvider>();
    final success = isEditing
        ? await provider.updateAnimal(animal)
        : await provider.addAnimal(animal);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEditing ? 'Animal actualizado' : 'Animal agregado')),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El ID visible ya existe')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.animal == null ? 'Agregar Animal' : 'Editar Animal'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 16,
            children: [
              TextFormField(
                controller: _idVisibleController,
                decoration: const InputDecoration(
                  labelText: 'ID Visible *',
                  hintText: 'Ej: 7, 0423',
                ),
                validator: Validators.validateIdVisible,
                enabled: widget.animal == null,
              ),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre (opcional)',
                  hintText: 'Ej: Lucero',
                ),
              ),
              TextFormField(
                controller: _razaController,
                decoration: const InputDecoration(
                  labelText: 'Raza *',
                  hintText: 'Ej: Holstein',
                ),
                validator: Validators.validateRaza,
              ),
              TextFormField(
                controller: _mesesController,
                decoration: const InputDecoration(
                  labelText: 'Meses de Embarazo *',
                  hintText: 'Ej: 6',
                ),
                keyboardType: TextInputType.number,
                validator: Validators.validateMeses,
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Último Palpado',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _fechaPalpado == null
                                ? 'Sin fecha'
                                : DateFormat('dd/MM/yyyy').format(_fechaPalpado!),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _selectDate(context),
                            icon: const Icon(Icons.calendar_today),
                            label: const Text('Cambiar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveAnimal,
                  child: Text(widget.animal == null ? 'Agregar' : 'Guardar Cambios'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
