import 'package:aurora_app/config/app_mode.dart';
import 'package:aurora_app/demo/demo_app.dart';
import 'package:aurora_app/screens/journal_screen.dart';
import 'package:aurora_app/services/journal_service.dart';
import 'package:aurora_app/services/memory_journal_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('demo boots and navigates to the real journal without Firebase',
      (tester) async {
    AppMode.isDemo = true;
    final journal = MemoryJournalService();
    JournalService.instance = journal;
    await tester.pumpWidget(DemoApp(journal: journal));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Welcome back, Alex'), findsOneWidget);
    await tester.tap(find.text('Open Journal'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(JournalScreen), findsOneWidget);
    expect(find.text('Title'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await journal.dispose();
    AppMode.isDemo = false;
  });
}
