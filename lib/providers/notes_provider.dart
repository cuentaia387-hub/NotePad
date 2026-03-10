import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';

enum SortOption { newest, oldest, titleAZ, titleZA }

class NotesProvider with ChangeNotifier {
  final Box<Note> _notesBox = Hive.box<Note>('notes_box');
  List<Note> _notes = [];
  String _searchQuery = '';
  SortOption _sortOption = SortOption.newest;

  NotesProvider() {
    _loadNotes();
  }

  SortOption get sortOption => _sortOption;

  List<Note> get allNotes {
    List<Note> active =
        _notes.where((n) => !n.isArchived).toList();

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      active = active
          .where((note) =>
              note.title.toLowerCase().contains(query) ||
              note.content.toLowerCase().contains(query) ||
              note.tags.any((t) => t.toLowerCase().contains(query)))
          .toList();
    }

    return active;
  }

  List<Note> get pinnedNotes => allNotes.where((n) => n.isPinned).toList();
  List<Note> get unpinnedNotes => allNotes.where((n) => !n.isPinned).toList();
  List<Note> get archivedNotes => _notes.where((n) => n.isArchived).toList();

  void _loadNotes() {
    _notes = _notesBox.values.toList();
    _sortNotes();
    notifyListeners();
  }

  void _sortNotes() {
    switch (_sortOption) {
      case SortOption.newest:
        _notes.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
        break;
      case SortOption.oldest:
        _notes.sort((a, b) => a.modifiedAt.compareTo(b.modifiedAt));
        break;
      case SortOption.titleAZ:
        _notes.sort((a, b) =>
            a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case SortOption.titleZA:
        _notes.sort((a, b) =>
            b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
    }
  }

  void setSort(SortOption option) {
    _sortOption = option;
    _sortNotes();
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addNote(
      String title, String content, Color color, List<String> tags) async {
    final note = Note(
      id: const Uuid().v4(),
      title: title,
      content: content,
      colorValue: color.value,
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
      tags: tags,
    );
    await _notesBox.put(note.id, note);
    _notes.add(note);
    _sortNotes();
    notifyListeners();
  }

  Future<void> updateNote(String id, String title, String content, Color color,
      List<String> tags) async {
    final noteIndex = _notes.indexWhere((n) => n.id == id);
    if (noteIndex != -1) {
      final note = _notes[noteIndex];
      note.title = title;
      note.content = content;
      note.colorValue = color.value;
      note.tags = tags;
      note.modifiedAt = DateTime.now();
      await _notesBox.put(id, note);
      _sortNotes();
      notifyListeners();
    }
  }

  Future<void> togglePin(String id) async {
    final noteIndex = _notes.indexWhere((n) => n.id == id);
    if (noteIndex != -1) {
      final note = _notes[noteIndex];
      note.isPinned = !note.isPinned;
      await _notesBox.put(id, note);
      notifyListeners();
    }
  }

  Future<void> toggleArchive(String id) async {
    final noteIndex = _notes.indexWhere((n) => n.id == id);
    if (noteIndex != -1) {
      final note = _notes[noteIndex];
      note.isArchived = !note.isArchived;
      // De-pin when archiving
      if (note.isArchived) note.isPinned = false;
      await _notesBox.put(id, note);
      notifyListeners();
    }
  }

  Future<void> deleteNote(String id) async {
    await _notesBox.delete(id);
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }
}
