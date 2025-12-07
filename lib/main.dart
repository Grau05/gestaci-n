import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestantes/database/database_helper.dart';
import 'package:gestantes/services/preferences_service.dart';
import 'package:gestantes/providers/animal_provider.dart';
import 'package:gestantes/screens/splash_screen.dart';
import 'package:gestantes/screens/onboarding_screen.dart';
import 'package:gestantes/screens/navigation_screen.dart';
import 'package:gestantes/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar preferencias
  await PreferencesService.init();
  
  // Inicializar BD
  final db = await DatabaseHelper.instance.database;
  
  // Verificar y crear columna etiquetas si no existe
  try {
    final tableInfo = await db.rawQuery('PRAGMA table_info(animals)');
    final columnNames = tableInfo.map((col) => col['name']).toList();
    
    if (!columnNames.contains('etiquetas')) {
      await db.execute('ALTER TABLE animals ADD COLUMN etiquetas TEXT DEFAULT \'\'');
    }
  } catch (e) {
    debugPrint('Error en verificación de columnas: $e');
  }
  
  // Verificar si ya vio onboarding
  final seenOnboarding = await PreferencesService.getBool('seen_onboarding');
  
  runApp(MyApp(seenOnboarding: seenOnboarding));
}

class MyApp extends StatelessWidget {
  final bool seenOnboarding;
  
  const MyApp({Key? key, required this.seenOnboarding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AnimalProvider()),
      ],
      child: MaterialApp(
        title: 'Gestantes',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: seenOnboarding ? const NavigationScreen() : const SplashScreen(),
        routes: {
          '/onboarding': (context) => const OnboardingScreen(),
          '/home': (context) => const NavigationScreen(),
        },
      ),
    );
  }
}
