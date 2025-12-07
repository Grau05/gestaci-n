import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestantes/providers/animal_provider.dart';
import 'package:gestantes/utils/gestation_calculator.dart';
import 'package:gestantes/screens/advanced_search_screen.dart';
import 'package:gestantes/screens/breed_comparison_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final animalProvider = context.watch<AnimalProvider>();
    final activeFarmName = animalProvider.activeFarm?.nombre;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AdvancedSearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.compare_arrows),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BreedComparisonScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<AnimalProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              spacing: 16,
              children: [
                _buildReminderBanner(context, provider),
                _buildQuickStats(context, provider),
                _buildNearDeliverySection(context, provider),
                _buildNeedPalpingSection(context, provider),
                _buildAlertsSection(context, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, AnimalProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Text(
          'Estadísticas Rápidas',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _buildStatCard(
              context,
              'Total Vacas',
              provider.allAnimals.length.toString(),
              Icons.pets,
            ),
            _buildStatCard(
              context,
              'Razas Únicas',
              provider.getRazas().length.toString(),
              Icons.category,
            ),
            _buildStatCard(
              context,
              'Prom. Gestación',
              '${provider.getAverageGestationDays().toStringAsFixed(0)} días',
              Icons.calendar_today,
            ),
            _buildStatCard(
              context,
              'Alertas Activas',
              provider.getAnimalsWithAlerts().length.toString(),
              Icons.warning,
              alertColor: true,
            ),
            _buildStatCard(
              context,
              'Preñadas',
              provider.allAnimals
                  .where((a) => a.estado == 'preñada')
                  .length
                  .toString(),
              Icons.pregnant_woman,
            ),
            _buildStatCard(
              context,
              'Paridas',
              provider.allAnimals
                  .where((a) => a.estado == 'parida')
                  .length
                  .toString(),
              Icons.baby_changing_station,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReminderBanner(BuildContext context, AnimalProvider provider) {
    final nearDelivery = provider.getAnimalsNearDelivery();
    final needPalping = provider.getAnimalsNeedingPalping();

    if (nearDelivery.isEmpty && needPalping.isEmpty) {
      return const SizedBox.shrink();
    }

    final messages = <String>[];
    if (nearDelivery.isNotEmpty) {
      messages.add('${nearDelivery.length} próximas a parir');
    }
    if (needPalping.isNotEmpty) {
      messages.add('${needPalping.length} necesitan palpado');
    }

    return Card(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.notifications_active,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    'Recordatorios de hoy',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    messages.join(' · '),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    bool alertColor = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            Icon(
              icon,
              size: 32,
              color: alertColor
                  ? Colors.orange
                  : Theme.of(context).colorScheme.primary,
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: alertColor ? Colors.orange : null,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearDeliverySection(
    BuildContext context,
    AnimalProvider provider,
  ) {
    final animals = provider.getAnimalsNearDelivery();
    if (animals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Text(
          'Próximas a Parir (2 semanas)',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        ...animals.take(5).map(
          (animal) {
            final daysUntil = GestationCalculator.daysUntilDelivery(animal);
            return Card(
              color: Colors.red[50],
              child: ListTile(
                leading: Icon(
                  Icons.pregnant_woman,
                  color: Colors.red,
                ),
                title: Text('Vaca ${animal.idVisible}'),
                subtitle: Text('${daysUntil} días para parto'),
                trailing: Icon(
                  Icons.arrow_forward,
                  color: Colors.red,
                ),
              ),
            );
          },
        ).toList(),
      ],
    );
  }

  Widget _buildNeedPalpingSection(
    BuildContext context,
    AnimalProvider provider,
  ) {
    final animals = provider.getAnimalsNeedingPalping();
    if (animals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Text(
          'Necesitan Palpado',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        ...animals.take(5).map(
          (animal) => Card(
            color: Colors.amber[50],
            child: ListTile(
              leading: Icon(Icons.schedule, color: Colors.amber[700]),
              title: Text('Vaca ${animal.idVisible}'),
              subtitle: Text(animal.raza),
              trailing: Icon(Icons.arrow_forward, color: Colors.amber[700]),
            ),
          ),
        ).toList(),
      ],
    );
  }

  Widget _buildAlertsSection(
    BuildContext context,
    AnimalProvider provider,
  ) {
    final animals = provider.getAnimalsWithAlerts();
    if (animals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Text(
          'Alertas Activas',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        ...animals.take(5).map(
          (animal) {
            final riskType = GestationCalculator.classifyRisk(animal);
            final riskInfo = GestationCalculator.getRiskInfo(riskType);
            return Card(
              child: ListTile(
                leading: Icon(Icons.warning, color: Color(riskInfo['color'])),
                title: Text('Vaca ${animal.idVisible}'),
                subtitle: Text(riskInfo['label']),
                trailing: Icon(Icons.info_outline),
              ),
            );
          },
        ).toList(),
      ],
    );
  }
}
