import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/journal_entry.dart';

/// JournalService
/// Lightweight Firestore wrapper for per-user journal CRUD operations.
/// Collection layout: `users/{uid}/journalEntries/{autoId}`.
/// All timestamps use server time for consistency across clients.
/// Throws a FirebaseException with `code: no-current-user` when invoked
/// without an authenticated user.

abstract class JournalService {
  static JournalService? _instance;
  static JournalService get instance => _instance ??= FirestoreJournalService();
  static set instance(JournalService service) => _instance = service;
  String? get userId;
  Stream<List<JournalEntry>> journalEntriesStream();
  Future<void> addEntry(
      {required String title,
      required String content,
      String mood = 'neutral'});
  Future<void> deleteEntry(String entryId);
  Future<void> updateEntry(String entryId,
      {String? title, String? content, String? mood});
  Future<Map<String, dynamic>?> getEntry(String entryId);
}

class FirestoreJournalService implements JournalService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  String? get userId => _auth.currentUser?.uid;

  /// Streams current user's journal entries ordered newest‑first.
  ///
  /// Throws a `FirebaseException(code: no-current-user)` if called while no
  /// user is authenticated (caller should catch and present appropriate UI).
  @override
  Stream<List<JournalEntry>> journalEntriesStream() {
    final uid = userId;
    if (uid == null) {
      throw FirebaseException(
          plugin: 'auth',
          code: 'no-current-user',
          message: 'No authenticated user found.');
    }
    return _db
        .collection('users')
        .doc(uid)
        .collection('journalEntries')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return JournalEntry(
                  id: doc.id,
                  title: data['title'] as String? ?? '',
                  content: data['content'] as String? ?? '',
                  mood: data['mood'] as String? ?? 'neutral',
                  createdAt: (data['createdAt'] as Timestamp?)?.toDate() ??
                      DateTime.now());
            }).toList());
  }

  /// Adds a new journal entry document for the current user.
  /// Trims [title] & [content] and stamps server timestamps for creation + update.
  @override
  Future<void> addEntry({
    required String title,
    required String content,
    String mood = 'neutral',
  }) async {
    final uid = userId;
    if (uid == null) {
      throw FirebaseException(
          plugin: 'auth',
          code: 'no-current-user',
          message: 'No user signed in.');
    }
    await _db.collection('users').doc(uid).collection('journalEntries').add({
      'title': title.trim(),
      'content': content.trim(),
      'mood': mood,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Deletes a journal entry by [entryId] (no-op if it doesn't exist).
  @override
  Future<void> deleteEntry(String entryId) async {
    final uid = userId;
    if (uid == null) {
      throw FirebaseException(
          plugin: 'auth',
          code: 'no-current-user',
          message: 'No user signed in.');
    }
    await _db
        .collection('users')
        .doc(uid)
        .collection('journalEntries')
        .doc(entryId)
        .delete();
  }

  /// Updates an existing entry (identified by [entryId]) with provided non‑null fields.
  /// Only changed fields are written; if no changes (besides timestamp) the write is skipped.
  @override
  Future<void> updateEntry(
    String entryId, {
    String? title,
    String? content,
    String? mood,
  }) async {
    final uid = userId;
    if (uid == null) {
      throw FirebaseException(
          plugin: 'auth',
          code: 'no-current-user',
          message: 'No user signed in.');
    }
    final Map<String, dynamic> update = {
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (title != null) update['title'] = title.trim();
    if (content != null) update['content'] = content.trim();
    if (mood != null) update['mood'] = mood;
    if (update.length == 1) {
      return; // only timestamp present => skip Firestore write to reduce churn
    }
    await _db
        .collection('users')
        .doc(uid)
        .collection('journalEntries')
        .doc(entryId)
        .set(update, SetOptions(merge: true));
  }

  /// Fetches a single entry document, returns null if not found.
  /// Caller can distinguish missing documents by a null return versus exception.
  @override
  Future<Map<String, dynamic>?> getEntry(String entryId) async {
    final uid = userId;
    if (uid == null) {
      throw FirebaseException(
          plugin: 'auth',
          code: 'no-current-user',
          message: 'No user signed in.');
    }
    final doc = await _db
        .collection('users')
        .doc(uid)
        .collection('journalEntries')
        .doc(entryId)
        .get();
    if (!doc.exists) return null;
    return doc.data();
  }
}
