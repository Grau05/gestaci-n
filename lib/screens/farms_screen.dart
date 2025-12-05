import 'package:flutter/material.dart';
import 'package:gestantes/models/farm.dart';
import 'package:gestantes/database/database_helper.dart';

class FarmsScreen extends StatefulWidget {
  const FarmsScreen({Key? key}) : super(key: key);

  @override
  State<FarmsScreen> createState() => _FarmsScreenState();
}

class _FarmsScreenState extends State<FarmsScreen> {
  List<Farm> _farms = [];

  @override
  void initState() {
    super.initState();
    _loadFarms();
  }

  Future<void> _loadFarms() async {
    final farms = await DatabaseHelper.instance.getAllFarms();
    setState(() => _farms = farms);
  }

  void _showAddFarmDialog() {
    final nameController = TextEditingController();
    final ubicacionController = TextEditingController();
    final encargadoController = TextEditingController();

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
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              TextField(
                controller: ubicacionController,
                decoration: InputDecoration(
                  labelText: 'Ubicación',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              TextField(
                controller: encargadoController,
                decoration: InputDecoration(
                  labelText: 'Encargado',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final farm = Farm(
                nombre: nameController.text,
                ubicacion: ubicacionController.text.isEmpty ? null : ubicacionController.text,
                encargado: encargadoController.text.isEmpty ? null : encargadoController.text,
              );
              await DatabaseHelper.instance.insertFarm(farm);
              await _loadFarms();
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fincas'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddFarmDialog,
          ),
        ],
      ),
      body: _farms.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.landscape, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('Sin fincas registradas'),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _showAddFarmDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Crear Finca'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _farms.length,
              itemBuilder: (context, index) {
                final farm = _farms[index];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(Icons.agriculture, color: Colors.green),
                    title: Text(farm.nombre),
                    subtitle: farm.ubicacion != null ? Text(farm.ubicacion!) : null,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await DatabaseHelper.instance.deleteFarm(farm.id!);
                        await _loadFarms();
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
