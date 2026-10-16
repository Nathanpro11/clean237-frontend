import 'package:clean237_frontend/main.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Dashboard is rendered without overflow at 360 px', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const Clean237App());
    await tester.pumpAndSettle();

    expect(find.text('Tableau de bord'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

}
