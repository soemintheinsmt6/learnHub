import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:learn_hub/main.dart';
import 'package:learn_hub/features/bottom_navigation_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'app loads home with bottom navigation',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.byType(BottomNavigationScreen), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    },
  );
}

