import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestantes/providers/animal_provider.dart';
import 'package:gestantes/screens/add_edit_animal_screen.dart';
import 'package:gestantes/screens/dashboard_screen.dart';
import 'package:gestantes/screens/detail_animal_screen.dart';
import 'package:gestantes/screens/statistics_screen.dart';
import 'package:gestantes/widgets/animal_card.dart';
import 'package:gestantes/widgets/search_filter_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestantes'),
        elevation: 0,
        actions: [
          Consumer<AnimalProvider>(
            builder: (context, provider, _) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Center(
                  child: DropdownButton<int>(
                    value: provider.currentFarmId,
                    items: provider.farms
                        .map(
                          (farm) => DropdownMenuItem(
                            value: farm.id,
                            child: Text(farm.nombre),
                          ),
                        )
                        .toList(),
                    onChanged: (farmId) {
                      if (farmId != null) {
                        provider.loadAnimalsByFarm(farmId);
                      }
                    },
                    dropdownColor: Theme.of(context).colorScheme.surface,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StatisticsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<AnimalProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: SearchFilterWidget(),
              ),
              Expanded(
                child: provider.animals.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.pets,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay animales registrados',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Toca el botón + para agregar',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: provider.animals.length,
                        itemBuilder: (context, index) {
                          final animal = provider.animals[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DetailAnimalScreen(animal: animal),
                                ),
                              );
                            },
                            child: AnimalCard(animal: animal),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddEditAnimalScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
