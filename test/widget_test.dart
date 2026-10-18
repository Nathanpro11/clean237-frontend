// Test de démarrage basique, généré par défaut par Flutter.
// Corrigé pour référencer la vraie classe racine de l'app : Clean237App
// (au lieu de 'MyApp', qui n'a jamais existé dans ce projet).
import 'package:flutter_test/flutter_test.dart';
import 'package:clean237_frontend/main.dart';

void main() {
  testWidgets('L\'application se lance sans erreur', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const Clean237App());
    await tester.pumpAndSettle();
    // Vérifie simplement que le widget racine s'est construit sans exception.
    expect(find.byType(Clean237App), findsOneWidget);
  });
}
