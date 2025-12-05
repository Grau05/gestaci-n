import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gestantes/providers/animal_provider.dart';
import 'package:gestantes/utils/csv_exporter.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportCSV(context),
          ),
        ],
      ),
      body: Consumer<AnimalProvider>(
        builder: (context, provider, _) {
          if (provider.allAnimals.isEmpty) {
            return const Center(
              child: Text('No hay datos para mostrar'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              spacing: 24,
              children: [
                _buildSummaryCards(context, provider),
                _buildMesesChart(context, provider),
                _buildRazaChart(context, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, AnimalProvider provider) {
    return Row(
      spacing: 12,
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                spacing: 8,
                children: [
                  Text(
                    'Total',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    provider.allAnimals.length.toString(),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                spacing: 8,
                children: [
                  Text(
                    'Razas',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    provider.getRazas().length.toString(),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                spacing: 8,
                children: [
                  Text(
                    'Prom. Meses',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    (provider.allAnimals.fold<int>(0, (sum, a) => sum + a.mesesEmbarazo) /
                            provider.allAnimals.length)
                        .toStringAsFixed(1),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMesesChart(BuildContext context, AnimalProvider provider) {
    final distribution = provider.getMesesDistribution();
    final entries = distribution.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distribución por Meses',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  barGroups: entries
                      .asMap()
                      .entries
                      .map(
                        (e) => BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: e.value.value.toDouble(),
                              color: Colors.green,
                            ),
                          ],
                        ),
                      )
                      .toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${entries[value.toInt()].key}');
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRazaChart(BuildContext context, AnimalProvider provider) {
    final razaCount = provider.getRazaCount();
    final entries = razaCount.entries.toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distribución por Raza',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sections: entries
                      .asMap()
                      .entries
                      .map(
                        (e) => PieChartSectionData(
                          value: e.value.value.toDouble(),
                          title: '${e.value.value}',
                          radius: 100,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: entries
                  .map(
                    (e) => Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.primaries[entries.indexOf(e) % Colors.primaries.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${e.key}: ${e.value}'),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _exportCSV(BuildContext context) {
    final provider = context.read<AnimalProvider>();
    final csv = CsvExporter.exportToCSV(provider.allAnimals);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('CSV generado (${csv.length} bytes)'),
        action: SnackBarAction(
          label: 'Copiar',
          onPressed: () {
            // En producción, usar flutter_clipboard
          },
        ),
      ),
    );
  }
}
