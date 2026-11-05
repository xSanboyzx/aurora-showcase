import 'package:aurora_app/services/memory_journal_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MemoryJournalService journal;
  setUp(() =>
      journal = MemoryJournalService(clock: () => DateTime(2026, 11, 5, 12)));
  tearDown(() => journal.dispose());

  test('seeds a full month, newest first, with an isolated session', () {
    expect(journal.entries, hasLength(30));
    expect(journal.entries.first.createdAt, DateTime(2026, 11, 5, 9));
    expect(journal.entries.last.createdAt, DateTime(2026, 10, 7, 9));
  });

  test('streams create, edit, delete and reset to every subscriber', () async {
    final first = <int>[];
    final second = <int>[];
    final a = journal
        .journalEntriesStream()
        .listen((entries) => first.add(entries.length));
    final b = journal
        .journalEntriesStream()
        .listen((entries) => second.add(entries.length));
    await Future<void>.delayed(Duration.zero);
    await journal.addEntry(title: ' Test ', content: ' Sample ', mood: 'happy');
    final entry = journal.entries.first;
    expect(entry.title, 'Test');
    await journal.updateEntry(entry.id, title: 'Edited', mood: 'calm');
    expect((await journal.getEntry(entry.id))?['mood'], 'calm');
    expect(journal.entries.first.createdAt, entry.createdAt);
    await journal.deleteEntry(entry.id);
    expect(await journal.getEntry(entry.id), isNull);
    journal.reset();
    await Future<void>.delayed(Duration.zero);
    expect(first, [30, 31, 31, 30, 30]);
    expect(second, first);
    await a.cancel();
    await b.cancel();
  });

  test('rejects empty reflections and updates to missing entries', () async {
    await expectLater(
        journal.addEntry(title: ' ', content: ''), throwsArgumentError);
    await expectLater(
        journal.updateEntry('missing', title: 'Changed'), throwsStateError);
    expect(journal.entries, hasLength(30));
  });
}
