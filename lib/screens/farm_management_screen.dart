import 'package:flutter/material.dart';
import 'package:gestantes/database/database_helper.dart';
import 'package:gestantes/models/farm.dart';

class FarmManagementScreen extends StatefulWidget {
  const FarmManagementScreen({super.key});

  @override
  State<FarmManagementScreen> createState() => _FarmManagementScreenState();
}

class _FarmManagementScreenState extends State<FarmManagementScreen> {
  List<Farm> _farms = [];
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _managerController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _locationController = TextEditingController();
    _managerController = TextEditingController();
    _loadFarms();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _managerController.dispose();
    super.dispose();
  }

  Future<void> _loadFarms() async {
    final farms = await DatabaseHelper.instance.getAllFarms();
    setState(() => _farms = farms);
  }

  void _showAddFarmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Nueva Finca'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre *'),
              ),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Ubicación'),
              ),
              TextField(
                controller: _managerController,
                decoration: const InputDecoration(labelText: 'Encargado'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _nameController.clear();
              _locationController.clear();
              _managerController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (_nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('El nombre es obligatorio')),
                );
                return;
              }
              _addFarm();
              Navigator.pop(context);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  Future<void> _addFarm() async {
    final farm = Farm(
      nombre: _nameController.text.trim(),
      ubicacion: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      encargado: _managerController.text.trim().isEmpty
          ? null
          : _managerController.text.trim(),
    );

    await DatabaseHelper.instance.insertFarm(farm);
    _nameController.clear();
    _locationController.clear();
    _managerController.clear();
    await _loadFarms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Fincas'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 16,
          children: [
            if (_farms.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(Icons.agriculture, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('Sin fincas registradas'),
                    ],
                  ),
                ),
              )
            else
              Column(
                spacing: 12,
                children: _farms
                    .map((farm) => Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.location_on,
                            color: Theme.of(context).colorScheme.primary),
                        title: Text(farm.nombre),
                        subtitle: farm.ubicacion != null
                            ? Text(farm.ubicacion!)
                            : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await DatabaseHelper.instance.deleteFarm(farm.id!);
                            await _loadFarms();
                          },
                        ),
                      ),
                    ))
                    .toList(),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddFarmDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Finca'),
      ),
    );
  }
}
