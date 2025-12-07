import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestantes/providers/animal_provider.dart';
import 'package:gestantes/screens/home_screen.dart';
import 'package:gestantes/screens/dashboard_screen.dart';
import 'package:gestantes/screens/statistics_screen.dart';
import 'package:gestantes/screens/notifications_screen.dart';
import 'package:gestantes/screens/settings_screen.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const DashboardScreen(),
    const StatisticsScreen(),
    const NotificationsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.pets),
              label: 'Animales',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Estadisticas',
            ),
            BottomNavigationBarItem(
              icon: Consumer<AnimalProvider>(
                builder: (context, provider, _) {
                  final alertCount = provider.allAnimals
                      .where((a) => a.mesesEmbarazo >= 8)
                      .length;

                  if (alertCount == 0) {
                    return const Icon(Icons.notifications);
                  }

                  return Badge(
                    label: Text('$alertCount'),
                    child: const Icon(Icons.notifications),
                  );
                },
              ),
              label: 'Notificaciones',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Ajustes',
            ),
          ],
        ),
      ),
    );
  }
}
