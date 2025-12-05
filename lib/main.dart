import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestantes/database/database_helper.dart';
import 'package:gestantes/providers/animal_provider.dart';
import 'package:gestantes/screens/navigation_screen.dart';
import 'package:gestantes/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
        home: const NavigationScreen(),
      ),
    );
  }
}
