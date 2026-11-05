import 'package:flutter/material.dart';

import 'config/app_mode.dart';
import 'demo/demo_app.dart';
import 'services/journal_service.dart';
import 'services/memory_journal_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppMode.isDemo = true;
  final journal = MemoryJournalService();
  JournalService.instance = journal;
  runApp(DemoApp(journal: journal));
}
