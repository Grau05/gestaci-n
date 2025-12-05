import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestantes/models/animal.dart';
import 'package:gestantes/providers/animal_provider.dart';
import 'package:intl/intl.dart';

class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({Key? key}) : super(key: key);

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  String? _selectedRaza;
  String? _selectedEstado;
  int? _mesesMin;
  int? _mesesMax;
  List<Animal> _resultados = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Búsqueda Avanzada'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<AnimalProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              spacing: 16,
              children: [
                _buildRangeCard(context),
                _buildRazaCard(context, provider),
                _buildEstadoCard(context),
                _buildGestationCard(context),
                ElevatedButton.icon(
                  onPressed: () => _buscar(provider),
                  icon: const Icon(Icons.search),
                  label: const Text('Buscar'),
                ),
                if (_resultados.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${_resultados.length} resultado(s) encontrado(s)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  ..._resultados.map((animal) => Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Icon(Icons.pets),
                      title: Text('${animal.idVisible} - ${animal.nombre ?? animal.raza}'),
                      subtitle: Text('${animal.mesesEmbarazo} meses - ${animal.estado}'),
                    ),
                  )),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRangeCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          spacing: 12,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rango de Fechas de Palpado'),
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_fechaInicio == null
                        ? 'Desde'
                        : DateFormat('dd/MM').format(_fechaInicio!)),
                    onPressed: () => _selectDate(context, true),
                  ),
                ),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_fechaFin == null
                        ? 'Hasta'
                        : DateFormat('dd/MM').format(_fechaFin!)),
                    onPressed: () => _selectDate(context, false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRazaCard(BuildContext context, AnimalProvider provider) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: DropdownButtonFormField<String>(
          value: _selectedRaza,
          decoration: const InputDecoration(
            labelText: 'Raza',
            border: InputBorder.none,
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('Todas')),
            ...provider.getRazas().map((r) => DropdownMenuItem(value: r, child: Text(r))),
          ],
          onChanged: (value) => setState(() => _selectedRaza = value),
        ),
      ),
    );
  }

  Widget _buildEstadoCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: DropdownButtonFormField<String>(
          value: _selectedEstado,
          decoration: const InputDecoration(
            labelText: 'Estado',
            border: InputBorder.none,
          ),
          items: const [
            DropdownMenuItem(value: null, child: Text('Todos')),
            DropdownMenuItem(value: 'preñada', child: Text('Preñada')),
            DropdownMenuItem(value: 'vacía', child: Text('Vacía')),
            DropdownMenuItem(value: 'dudosa', child: Text('Dudosa')),
            DropdownMenuItem(value: 'parida', child: Text('Parida')),
          ],
          onChanged: (value) => setState(() => _selectedEstado = value),
        ),
      ),
    );
  }

  Widget _buildGestationCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          spacing: 12,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Meses de Gestación'),
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Min'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(() => _mesesMin = int.tryParse(v)),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Max'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(() => _mesesMax = int.tryParse(v)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _fechaInicio = picked;
        } else {
          _fechaFin = picked;
        }
      });
    }
  }

  void _buscar(AnimalProvider provider) {
    _resultados = provider.allAnimals.where((animal) {
      if (_fechaInicio != null &&
          animal.fechaUltimoPalpado != null &&
          animal.fechaUltimoPalpado!.isBefore(_fechaInicio!)) {
        return false;
      }
      if (_fechaFin != null &&
          animal.fechaUltimoPalpado != null &&
          animal.fechaUltimoPalpado!.isAfter(_fechaFin!)) {
        return false;
      }
      if (_selectedRaza != null && animal.raza != _selectedRaza) return false;
      if (_selectedEstado != null && animal.estado != _selectedEstado) return false;
      if (_mesesMin != null && animal.mesesEmbarazo < _mesesMin!) return false;
      if (_mesesMax != null && animal.mesesEmbarazo > _mesesMax!) return false;
      return true;
    }).toList();
    setState(() {});
  }
}
