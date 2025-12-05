import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gestantes/providers/animal_provider.dart';

class BreedComparisonScreen extends StatelessWidget {
  const BreedComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparacion de Razas'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<AnimalProvider>(
        builder: (context, provider, _) {
          if (provider.allAnimals.isEmpty) {
            return const Center(child: Text('Sin datos'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              spacing: 20,
              children: [
                _buildBreedStatsChart(context, provider),
                _buildBreedDetailsCard(context, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBreedStatsChart(BuildContext context, AnimalProvider provider) {
    final razaCount = provider.getRazaCount();
    final entries = razaCount.entries.toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cantidad por Raza',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  barGroups: entries
                      .asMap()
                      .entries
                      .map((e) => BarChartGroupData(
                        x: e.key,
                        barRods: [
                          BarChartRodData(
                            toY: e.value.value.toDouble(),
                            color: Colors.primaries[e.key % Colors.primaries.length],
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                          ),
                        ],
                      ))
                      .toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            entries[value.toInt()].key,
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreedDetailsCard(BuildContext context, AnimalProvider provider) {
    final animals = provider.allAnimals;
    final razaStats = <String, Map<String, dynamic>>{};

    for (var animal in animals) {
      if (!razaStats.containsKey(animal.raza)) {
        razaStats[animal.raza] = {
          'count': 0,
          'totalMeses': 0,
          'pregnantCount': 0,
          'emptyCount': 0,
          'paridas': 0,
        };
      }
      razaStats[animal.raza]!['count']++;
      razaStats[animal.raza]!['totalMeses'] += animal.mesesEmbarazo;
      if (animal.estado == 'preñada') razaStats[animal.raza]!['pregnantCount']++;
      if (animal.estado == 'vacía') razaStats[animal.raza]!['emptyCount']++;
      if (animal.estado == 'parida') razaStats[animal.raza]!['paridas']++;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Text(
              'Estadisticas por Raza',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            ...razaStats.entries.map((e) {
              final stats = e.value;
              final promMeses = (stats['totalMeses'] as int) ~/ (stats['count'] as int);
              return _buildBreedStatRow(
                context,
                e.key,
                stats['count'] as int,
                promMeses,
                stats['pregnantCount'] as int,
                stats['emptyCount'] as int,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBreedStatRow(
    BuildContext context,
    String raza,
    int total,
    int promMeses,
    int pregnantCount,
    int emptyCount,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(
            raza,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statBadge('Total: $total'),
              _statBadge('Prom: $promMeses m'),
              _statBadge('Prenadas: $pregnantCount'),
              _statBadge('Vacias: $emptyCount'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
