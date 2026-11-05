/// Application journal data, independent of the storage provider.
class JournalEntry {
  const JournalEntry(
      {required this.id,
      required this.title,
      required this.content,
      required this.mood,
      required this.createdAt});
  final String id;
  final String title;
  final String content;
  final String mood;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
        'title': title,
        'content': content,
        'mood': mood,
        'createdAt': createdAt,
      };
}
