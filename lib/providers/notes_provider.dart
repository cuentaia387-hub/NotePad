import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';

class NotesProvider with ChangeNotifier {
  final Box<Note> _notesBox = Hive.box<Note>('notes_box');
  List<Note> _notes = [];
  String _searchQuery = '';

  NotesProvider() {
    _loadNotes();
  }

  List<Note> get allNotes {
    if (_searchQuery.isEmpty) return _notes;
    
    final query = _searchQuery.toLowerCase();
    return _notes.where((note) {
      return note.title.toLowerCase().contains(query) || 
             note.content.toLowerCase().contains(query);
    }).toList();
  }

  List<Note> get pinnedNotes => allNotes.where((n) => n.isPinned && !n.isArchived).toList();
  List<Note> get unpinnedNotes => allNotes.where((n) => !n.isPinned && !n.isArchived).toList();
  List<Note> get archivedNotes => allNotes.where((n) => n.isArchived).toList();

  void _loadNotes() {
    _notes = _notesBox.values.toList();
    _sortNotes();
    notifyListeners();
  }

  void _sortNotes() {
    _notes.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addNote(String title, String content, Color color, List<String> tags) async {
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

  Future<void> updateNote(String id, String title, String content, Color color, List<String> tags) async {
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
