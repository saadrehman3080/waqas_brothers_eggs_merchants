import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:waqas_brothers_eggs_merchants/views/widgets/app_button.dart';

void main() {
  testWidgets('AppButton renders label and fires onPressed',
      (WidgetTester tester) async {
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppButton(
              label: 'Save',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Save'), findsOneWidget);
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(pressed, isTrue);
  });
}
