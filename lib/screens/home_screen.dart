import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestantes/providers/animal_provider.dart';
import 'package:gestantes/models/farm.dart';
import 'package:gestantes/screens/add_edit_animal_screen.dart';
import 'package:gestantes/screens/detail_animal_screen.dart';
import 'package:gestantes/widgets/animal_card.dart';
import 'package:gestantes/widgets/search_filter_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _filterEstado;

  @override
  Widget build(BuildContext context) {
    final animalProvider = context.watch<AnimalProvider>();
    final activeFarmName = animalProvider.activeFarm?.nombre;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Gestantes',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.transparent,
        bottom: activeFarmName != null
            ? PreferredSize(
                preferredSize: const Size.fromHeight(24),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    activeFarmName,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey),
                  ),
                ),
              )
            : null,
      ),
      body: Consumer<AnimalProvider>(
        builder: (context, provider, _) {
          var filteredAnimals = provider.animals;
          if (_filterEstado != null) {
            filteredAnimals = filteredAnimals
                .where((a) => a.estado == _filterEstado)
                .toList();
          }

          return Column(
            children: [
              if (provider.farms.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Finca',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      DropdownButton<Farm>(
                        value: provider.activeFarm,
                        hint: const Text('Selecciona una finca'),
                        onChanged: (farm) {
                          if (farm != null && farm.id != null) {
                            provider.setActiveFarm(farm.id!);
                          }
                        },
                        items: provider.farms
                            .map(
                              (farm) => DropdownMenuItem<Farm>(
                                value: farm,
                                child: Text(farm.nombre),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SearchFilterWidget(),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Todas'),
                      selected: _filterEstado == null,
                      onSelected: (selected) {
                        setState(() => _filterEstado = null);
                      },
                    ),
                    FilterChip(
                      label: const Text('Prenadas'),
                      selected: _filterEstado == 'preñada',
                      onSelected: (selected) {
                        setState(() => _filterEstado = 'preñada');
                      },
                    ),
                    FilterChip(
                      label: const Text('Vacias'),
                      selected: _filterEstado == 'vacía',
                      onSelected: (selected) {
                        setState(() => _filterEstado = 'vacía');
                      },
                    ),
                    FilterChip(
                      label: const Text('Paridas'),
                      selected: _filterEstado == 'parida',
                      onSelected: (selected) {
                        setState(() => _filterEstado = 'parida');
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredAnimals.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filteredAnimals.length,
                      itemBuilder: (context, index) {
                        final animal = filteredAnimals[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DetailAnimalScreen(animal: animal),
                                ),
                              );
                            },
                            child: Hero(
                              tag: 'animal-${animal.idInterno}',
                              child: AnimalCard(animal: animal),
                            ),
                          ),
                        );
                      },
                    ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddEditAnimalScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Animal'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.pets,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay animales registrados',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega tu primer animal para comenzar',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
