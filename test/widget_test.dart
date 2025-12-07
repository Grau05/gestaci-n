// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gestantes/main.dart';
import 'package:gestantes/screens/navigation_screen.dart';
import 'package:gestantes/screens/dashboard_screen.dart';

void main() {
  testWidgets('Gestantes app loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp(seenOnboarding: true));

    // Verificar que la app se cargó correctamente
    expect(find.byType(NavigationScreen), findsOneWidget);
    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('Navigation screen displays bottom navigation bar',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(seenOnboarding: true));

    // Verificar que existe barra de navegación
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    
    // Verificar que hay 5 items en la navegación
    expect(find.byType(BottomNavigationBarItem), findsNWidgets(5));
  });

  testWidgets('Can navigate between screens', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(seenOnboarding: true));

    // Tap en el segundo item (Dashboard)
    await tester.tap(find.byIcon(Icons.dashboard));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardScreen), findsOneWidget);
  });
}
