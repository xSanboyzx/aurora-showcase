import 'package:flutter/material.dart';

class DemoInfoScreen extends StatelessWidget {
  const DemoInfoScreen(
      {super.key, required this.title, required this.description});
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(
            child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.explore_outlined, size: 48),
                const SizedBox(height: 20),
                Text(description, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                const Text(
                    'Try the Journal, Timeline, and Resources tabs for interactive features.'),
              ])),
        )),
      );
}

class DemoChatScreen extends StatefulWidget {
  const DemoChatScreen({super.key});
  @override
  State<DemoChatScreen> createState() => _DemoChatScreenState();
}

class _DemoChatScreenState extends State<DemoChatScreen> {
  int _example = 0;
  static const _prompts = ['Starting a task', 'Reflecting on today'];
  static const _answers = [
    'You could choose one small step, like opening your notes. The focus timer in Resources can give that step a little structure.',
    'You might write down one thing that felt good and one thing you would like to make space for tomorrow. The Journal offers mood prompts to help you begin.',
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Aurora Chat · Examples')),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Prerecorded examples',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      const Text(
                          'These examples illustrate the chat interface’s intent. No live AI request is made, and no personal journal is sent anywhere.'),
                      const SizedBox(height: 24),
                      Wrap(
                          spacing: 8,
                          children: List.generate(
                              _prompts.length,
                              (index) => ChoiceChip(
                                    label: Text(_prompts[index]),
                                    selected: index == _example,
                                    onSelected: (_) =>
                                        setState(() => _example = index),
                                  ))),
                      const SizedBox(height: 24),
                      Card(
                          child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(_answers[_example]))),
                      const SizedBox(height: 16),
                      const Text(
                          'Student wellness prototype · Not medical advice or crisis support.'),
                    ],
                  )),
            )),
      );
}
