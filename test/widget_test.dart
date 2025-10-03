

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro9/Pagina_inicio/PagInicio.dart';


void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {

    await tester.pumpWidget(
  const MaterialApp(
    home: PagInicio(), // 👈 tu pantalla principal
  ),
);


    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

   
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

   
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
