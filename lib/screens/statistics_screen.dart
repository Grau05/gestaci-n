import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gestantes/providers/animal_provider.dart';
import 'package:gestantes/utils/csv_exporter.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Estadísticas',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.transparent,
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('No hay datos para mostrar'),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              spacing: 20,
              children: [
                _buildSummaryCards(context, provider),
                _buildMesesChartCard(context, provider),
                _buildRazaChartCard(context, provider),
                _buildStateChartCard(context, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, AnimalProvider provider) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildStatCard(
          context,
          'Total',
          provider.allAnimals.length.toString(),
          Icons.pets,
          Colors.blue,
        ),
        _buildStatCard(
          context,
          'Razas',
          provider.getRazas().length.toString(),
          Icons.category,
          Colors.purple,
        ),
        _buildStatCard(
          context,
          'Prom. Gestación',
          '${provider.allAnimals.fold<int>(0, (sum, a) => sum + a.mesesEmbarazo) ~/ provider.allAnimals.length} meses',
          Icons.calendar_today,
          Colors.green,
        ),
        _buildStatCard(
          context,
          'Críticas',
          provider.allAnimals.where((a) => a.mesesEmbarazo >= 8).length.toString(),
          Icons.warning,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            Icon(icon, size: 32, color: color),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMesesChartCard(BuildContext context, AnimalProvider provider) {
    final distribution = provider.getMesesDistribution();
    final entries = distribution.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distribucion por Meses',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  barGroups: entries
                      .asMap()
                      .entries
                      .map((e) {
                    final color = _getMonthColor(e.value.key);
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: e.value.value.toDouble(),
                          color: color,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                        ),
                      ],
                    );
                  })
                      .toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${entries[value.toInt()].key}m');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}');
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

  Widget _buildRazaChartCard(BuildContext context, AnimalProvider provider) {
    final razaCount = provider.getRazaCount();
    if (razaCount.isEmpty) return const SizedBox.shrink();

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Razas Registradas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: razaCount.entries.toList().asMap().entries.map((e) {
                    final index = e.key;
                    final entry = e.value;
                    return PieChartSectionData(
                      value: entry.value.toDouble(),
                      title: '${entry.value}',
                      color: colors[index % colors.length],
                      radius: 100,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Column(
              spacing: 8,
              children: razaCount.entries
                  .toList()
                  .asMap()
                  .entries
                  .map((e) {
                    final index = e.key;
                    final entry = e.value;
                    return Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: colors[index % colors.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${entry.key}: ${entry.value}'),
                      ],
                    );
                  })
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStateChartCard(BuildContext context, AnimalProvider provider) {
    final animals = provider.allAnimals;
    final states = {
      'preñada': animals.where((a) => a.estado == 'preñada').length,
      'vacía': animals.where((a) => a.estado == 'vacía').length,
      'dudosa': animals.where((a) => a.estado == 'dudosa').length,
      'parida': animals.where((a) => a.estado == 'parida').length,
    };

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Por Estado',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Column(
              spacing: 12,
              children: states.entries.map((e) {
                final color = _getStateColor(e.key);
                final percentage = (e.value / animals.length * 100).toStringAsFixed(1);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.key),
                        Text('${e.value} (${percentage}%)'),
                      ],
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: e.value / animals.length,
                        minHeight: 8,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMonthColor(int mes) {
    if (mes < 3) return Colors.blue;
    if (mes < 6) return Colors.cyan;
    if (mes < 8) return Colors.orange;
    return Colors.red;
  }

  Color _getStateColor(String state) {
    switch (state) {
      case 'preñada':
        return Colors.green;
      case 'vacía':
        return Colors.orange;
      case 'dudosa':
        return Colors.amber;
      case 'parida':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _exportCSV(BuildContext context) {
    final provider = context.read<AnimalProvider>();
    final csv = CsvExporter.exportToCSV(provider.allAnimals);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('CSV generado (${csv.length} bytes)'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
