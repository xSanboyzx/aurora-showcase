import 'dart:async';

import '../models/journal_entry.dart';
import 'journal_service.dart';

/// Session-only storage. Every visitor receives a separate fictional journal.
class MemoryJournalService implements JournalService {
  MemoryJournalService({DateTime Function()? clock})
      : _clock = clock ?? DateTime.now {
    reset();
  }

  final DateTime Function() _clock;
  final _changes = StreamController<List<JournalEntry>>.broadcast(sync: true);
  final Map<String, JournalEntry> _entries = {};
  int _nextId = 0;

  @override
  String get userId => 'demo-alex';

  List<JournalEntry> get entries => List.unmodifiable(
        _entries.values.toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
      );

  void reset() {
    _entries.clear();
    _nextId = 0;
    final today = _clock();
    const titles = [
      'A quieter morning',
      'One thing at a time',
      'A walk outside',
      'Making room for rest',
      'A small win'
    ];
    const moods = ['calm', 'tired', 'happy', 'neutral', 'grateful'];
    const reflections = [
      'I took a few minutes before starting the day. A slower morning helped me settle in.',
      'There was a lot to do. Breaking one task into smaller steps made it easier to start.',
      'A short walk and a conversation with a friend were highlights of the day.',
      'I stepped away from my screen and made time for a break.',
      'I finished something I had been putting off. Small progress still counts.',
    ];
    for (var day = 0; day < 30; day++) {
      final id = 'sample-$day';
      _entries[id] = JournalEntry(
          id: id,
          title: titles[day % titles.length],
          content: reflections[day % reflections.length],
          mood: moods[day % moods.length],
          createdAt: DateTime(today.year, today.month, today.day - day, 9));
    }
    _changes.add(entries);
  }

  @override
  Stream<List<JournalEntry>> journalEntriesStream() => Stream.multi((listener) {
        listener.add(entries);
        final subscription = _changes.stream.listen(listener.add);
        listener.onCancel = subscription.cancel;
      });

  @override
  Future<void> addEntry(
      {required String title,
      required String content,
      String mood = 'neutral'}) async {
    if (title.trim().isEmpty && content.trim().isEmpty) {
      throw ArgumentError('Write a title or reflection first.');
    }
    final id = 'session-${_nextId++}';
    _entries[id] = JournalEntry(
        id: id,
        title: title.trim(),
        content: content.trim(),
        mood: mood,
        createdAt: _clock());
    _changes.add(entries);
  }

  @override
  Future<void> updateEntry(String entryId,
      {String? title, String? content, String? mood}) async {
    final previous = _entries[entryId];
    if (previous == null) {
      throw StateError('This journal entry no longer exists.');
    }
    final nextTitle = title?.trim() ?? previous.title;
    final nextContent = content?.trim() ?? previous.content;
    if (nextTitle.isEmpty && nextContent.isEmpty) {
      throw ArgumentError('Write a title or reflection first.');
    }
    _entries[entryId] = JournalEntry(
        id: entryId,
        title: nextTitle,
        content: nextContent,
        mood: mood ?? previous.mood,
        createdAt: previous.createdAt);
    _changes.add(entries);
  }

  @override
  Future<void> deleteEntry(String entryId) async {
    _entries.remove(entryId);
    _changes.add(entries);
  }

  @override
  Future<Map<String, dynamic>?> getEntry(String entryId) async =>
      _entries[entryId]?.toMap();

  Future<void> dispose() => _changes.close();
}
