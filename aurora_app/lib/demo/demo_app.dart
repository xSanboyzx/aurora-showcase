import 'package:flutter/material.dart';

import '../screens/aurora_shell.dart';
import '../services/memory_journal_service.dart';

class DemoApp extends StatefulWidget {
  const DemoApp({super.key, required this.journal});
  final MemoryJournalService journal;

  @override
  State<DemoApp> createState() => _DemoAppState();
}

class _DemoAppState extends State<DemoApp> {
  int _revision = 0;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Aurora · Interactive demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            useMaterial3: true,
            colorScheme:
                ColorScheme.fromSeed(seedColor: const Color(0xFFF5C97B))),
        home: Builder(
            builder: (context) => Scaffold(
                  body: SafeArea(
                      child: Column(children: [
                    Material(
                        color: const Color(0xFFEEE5D8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Row(children: [
                            const Expanded(
                                child: Text(
                                    'Aurora demo · Fictional data\nChanges clear on refresh',
                                    style: TextStyle(fontSize: 12))),
                            IconButton(
                                tooltip: 'About this demo',
                                icon: const Icon(Icons.info_outline),
                                onPressed: () => showDialog<void>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          title: const Text('Explore Aurora'),
                                          content: const SingleChildScrollView(
                                              child: Text(
                                                  'Try writing a journal entry, exploring mood trends, and using the focus tools.\n\nEverything stays in this tab’s memory. No accounts, location access, notifications, or live AI services are used. Chat examples are prerecorded. Please use fictional entries.\n\nAurora is a student project, not a medical service.\n\nOriginal project: Sunny Patel, Sanhith Amarathunge, Aakanksha Parekh, Paul Joseph, and Suthashan Tharmarajah. Showcase polish by Sanhith Amarathunge.')),
                                          actions: [
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text('Explore'))
                                          ],
                                        ))),
                            TextButton(
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                            title: const Text('Reset demo?'),
                                            content: const Text(
                                                'Your session changes will be replaced with the fictional sample journal.'),
                                            actions: [
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, false),
                                                  child: const Text('Cancel')),
                                              FilledButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, true),
                                                  child: const Text('Reset'))
                                            ],
                                          ));
                                  if (confirmed == true && mounted) {
                                    widget.journal.reset();
                                    setState(() => _revision++);
                                  }
                                },
                                child: const Text('Reset demo')),
                          ]),
                        )),
                    Expanded(child: AuroraShell(key: ValueKey(_revision))),
                  ])),
                )),
      );
}
