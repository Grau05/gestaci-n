import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestantes/models/animal.dart';
import 'package:gestantes/models/farm.dart';
import 'package:gestantes/providers/animal_provider.dart';
import 'package:gestantes/utils/validators.dart';
import 'package:gestantes/database/database_helper.dart';
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
  DateTime? _fechaMonta;
  String _estado = 'preñada';
  int _idFinca = 1;
  List<String> _etiquetas = [];
  List<Farm> _farms = [];
  final _formKey = GlobalKey<FormState>();
  
  static const List<String> _etiquetasDisponibles = [
    'Problema sanitario',
    'Venta',
    'Reproductor',
    'Monitoreo',
    'Tratamiento',
  ];

  @override
  void initState() {
    super.initState();
    _idVisibleController = TextEditingController(text: widget.animal?.idVisible ?? '');
    _nombreController = TextEditingController(text: widget.animal?.nombre ?? '');
    _razaController = TextEditingController(text: widget.animal?.raza ?? '');
    _mesesController = TextEditingController(text: widget.animal?.mesesEmbarazo.toString() ?? '');
    _fechaPalpado = widget.animal?.fechaUltimoPalpado;
    _fechaMonta = widget.animal?.fechaMonta;
    _estado = widget.animal?.estado ?? 'preñada';
    _idFinca = widget.animal?.idFinca ?? 1;
    _etiquetas = List.from(widget.animal?.etiquetas ?? []);
    _loadFarms();
  }

  Future<void> _loadFarms() async {
    final farms = await DatabaseHelper.instance.getAllFarms();
    setState(() => _farms = farms);
  }

  @override
  void dispose() {
    _idVisibleController.dispose();
    _nombreController.dispose();
    _razaController.dispose();
    _mesesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, {bool isMonta = false}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isMonta ? (_fechaMonta ?? DateTime.now()) : (_fechaPalpado ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isMonta) {
          _fechaMonta = picked;
        } else {
          _fechaPalpado = picked;
        }
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
      fechaMonta: _fechaMonta,
      estado: _estado,
      idFinca: _idFinca,
      etiquetas: _etiquetas,
      fechaRegistro: widget.animal?.fechaRegistro,
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
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 16,
            children: [
              TextFormField(
                controller: _idVisibleController,
                decoration: InputDecoration(
                  labelText: 'ID Visible *',
                  hintText: 'Ej: 7, 0423',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: Validators.validateIdVisible,
                enabled: widget.animal == null,
              ),
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre (opcional)',
                  hintText: 'Ej: Lucero',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              TextFormField(
                controller: _razaController,
                decoration: InputDecoration(
                  labelText: 'Raza *',
                  hintText: 'Ej: Holstein',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: Validators.validateRaza,
              ),
              DropdownButtonFormField<int>(
                value: _idFinca,
                decoration: InputDecoration(
                  labelText: 'Finca *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _farms.map((f) => DropdownMenuItem(value: f.id, child: Text(f.nombre))).toList(),
                onChanged: (value) => setState(() => _idFinca = value ?? 1),
              ),
              DropdownButtonFormField<String>(
                initialValue: _estado,
                decoration: InputDecoration(
                  labelText: 'Estado *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: 'preñada', child: Text('Preñada')),
                  DropdownMenuItem(value: 'vacía', child: Text('Vacía')),
                  DropdownMenuItem(value: 'dudosa', child: Text('Dudosa')),
                  DropdownMenuItem(value: 'parida', child: Text('Parida')),
                ],
                onChanged: (value) => setState(() => _estado = value ?? 'preñada'),
              ),
              TextFormField(
                controller: _mesesController,
                decoration: InputDecoration(
                  labelText: 'Meses de Embarazo *',
                  hintText: 'Ej: 6',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.number,
                validator: Validators.validateMeses,
              ),
              _buildDateCard(context, 'Fecha Monta', _fechaMonta, true),
              _buildDateCard(context, 'Ultimo Palpado', _fechaPalpado, false),
              _buildEtiquetasCard(context),
              const SizedBox(height: 16),
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

  Widget _buildDateCard(BuildContext context, String label, DateTime? date, bool isMonta) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date == null ? 'Sin fecha' : DateFormat('dd/MM/yyyy').format(date),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                ElevatedButton.icon(
                  onPressed: () => _selectDate(context, isMonta: isMonta),
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Cambiar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEtiquetasCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Text('Etiquetas', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _etiquetasDisponibles.map((tag) {
                final isSelected = _etiquetas.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _etiquetas.add(tag);
                      } else {
                        _etiquetas.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
