import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestantes/providers/animal_provider.dart';
import 'package:gestantes/utils/gestation_calculator.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _filterType = 'todos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<AnimalProvider>(
        builder: (context, provider, _) {
          final notifications = _buildNotifications(provider);
          
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay notificaciones',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Todas'),
                      selected: _filterType == 'todos',
                      onSelected: (_) {
                        setState(() => _filterType = 'todos');
                      },
                    ),
                    FilterChip(
                      label: const Text('Parto Proximo'),
                      selected: _filterType == 'parto',
                      onSelected: (_) {
                        setState(() => _filterType = 'parto');
                      },
                    ),
                    FilterChip(
                      label: const Text('Palpado Vencido'),
                      selected: _filterType == 'palpado',
                      onSelected: (_) {
                        setState(() => _filterType = 'palpado');
                      },
                    ),
                    FilterChip(
                      label: const Text('Riesgo Alto'),
                      selected: _filterType == 'riesgo',
                      onSelected: (_) {
                        setState(() => _filterType = 'riesgo');
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    return _buildNotificationCard(context, notif);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _buildNotifications(AnimalProvider provider) {
    final notifications = <Map<String, dynamic>>[];

    for (var animal in provider.allAnimals) {
      final riskType = GestationCalculator.classifyRisk(animal);

      // Notificacion: Parto proximo
      final daysUntil = GestationCalculator.daysUntilDelivery(animal);
      if (daysUntil >= 0 && daysUntil <= 14) {
        notifications.add({
          'type': 'parto',
          'animal': animal,
          'title': 'Parto Proximo',
          'message': 'Vaca ${animal.idVisible} parira en $daysUntil dias',
          'icon': Icons.pregnant_woman,
          'color': Colors.red,
          'priority': 1,
        });
      }

      // Notificacion: Palpado vencido
      if (animal.fechaUltimoPalpado != null) {
        final daysSincePalpado =
            DateTime.now().difference(animal.fechaUltimoPalpado!).inDays;
        if (daysSincePalpado > 60) {
          notifications.add({
            'type': 'palpado',
            'animal': animal,
            'title': 'Palpado VENCIDO',
            'message':
                'Vaca ${animal.idVisible} hace $daysSincePalpado dias sin palpado',
            'icon': Icons.medical_services,
            'color': Colors.orange,
            'priority': 2,
          });
        }
      }

      // Notificacion: Riesgo alto
      if (riskType == 'riesgo_alto') {
        notifications.add({
          'type': 'riesgo',
          'animal': animal,
          'title': 'RIESGO ALTO',
          'message': 'Vaca ${animal.idVisible} muy proxima al parto',
          'icon': Icons.warning,
          'color': Colors.red,
          'priority': 0,
        });
      }
    }

    // Filtrar
    if (_filterType != 'todos') {
      notifications.retainWhere((n) => n['type'] == _filterType);
    }

    // Ordenar por prioridad
    notifications.sort((a, b) => a['priority'].compareTo(b['priority']));

    return notifications;
  }

  Widget _buildNotificationCard(
    BuildContext context,
    Map<String, dynamic> notification,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(
              color: notification['color'],
              width: 4,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            spacing: 12,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: notification['color'].withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  notification['icon'],
                  color: notification['color'],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(
                      notification['title'],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: notification['color'],
                      ),
                    ),
                    Text(
                      notification['message'],
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'ID: ${notification['animal'].idVisible}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
