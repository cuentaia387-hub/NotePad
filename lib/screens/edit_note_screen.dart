import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/glass_toast.dart';

class EditNoteScreen extends StatefulWidget {
  final Note? note;

  const EditNoteScreen({Key? key, this.note}) : super(key: key);

  @override
  _EditNoteScreenState createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late Color _selectedColor;
  late List<String> _tags;
  final TextEditingController _tagController = TextEditingController();

  // Historial de deshacer
  final List<String> _undoHistory = [];
  bool _isUndoing = false;

  int get _wordCount => _contentController.text.trim().isEmpty
      ? 0
      : _contentController.text.trim().split(RegExp(r'\s+')).length;

  int get _charCount => _contentController.text.length;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _selectedColor = widget.note?.color ?? AppTheme.noteColors[0];
    _tags = List<String>.from(widget.note?.tags ?? []);

    _contentController.addListener(() {
      setState(() {});
      if (!_isUndoing) {
        _undoHistory.add(_contentController.text);
        if (_undoHistory.length > 50) _undoHistory.removeAt(0);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _undo() {
    if (_undoHistory.length >= 2) {
      _undoHistory.removeLast();
      _isUndoing = true;
      final prev = _undoHistory.last;
      _contentController.value = TextEditingValue(
        text: prev,
        selection: TextSelection.collapsed(offset: prev.length),
      );
      _isUndoing = false;
    }
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final provider = context.read<NotesProvider>();

    if (widget.note == null) {
      provider.addNote(title, content, _selectedColor, _tags);
    } else {
      provider.updateNote(widget.note!.id, title, content, _selectedColor, _tags);
    }

    Navigator.pop(context);
  }

  void _copyNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final text = title.isNotEmpty ? '$title\n\n$content' : content;
    Clipboard.setData(ClipboardData(text: text));
    GlassToast.show(
      context,
      message: 'Nota copiada al portapapeles',
      icon: Icons.copy_all_outlined,
      iconColor: AppTheme.neonAccent,
    );
  }

  void _addTag(String tag) {
    final trimmed = tag.trim();
    if (trimmed.isNotEmpty && !_tags.contains(trimmed)) {
      setState(() {
        _tags.add(trimmed);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  @override
  Widget build(BuildContext context) {
    final body = Scaffold(
      backgroundColor: AppTheme.pureBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
          onPressed: _saveNote,
        ),
        actions: [
          // Deshacer
          IconButton(
            icon: Icon(
              Icons.undo,
              color: _undoHistory.length >= 2 ? Colors.white70 : Colors.white24,
            ),
            tooltip: 'Deshacer',
            onPressed: _undoHistory.length >= 2 ? _undo : null,
          ),
          // Copiar
          IconButton(
            icon: const Icon(Icons.copy_outlined, color: Colors.white70),
            tooltip: 'Copiar todo',
            onPressed: _copyNote,
          ),
          // Guardar
          IconButton(
            icon: const Icon(Icons.check, color: AppTheme.neonAccent),
            tooltip: 'Guardar',
            onPressed: _saveNote,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                decoration: const InputDecoration(
                  hintText: 'Título',
                  hintStyle: TextStyle(color: Colors.white30),
                  border: InputBorder.none,
                ),
                maxLines: null,
              ),
              const SizedBox(height: 4),
              _buildColorPicker(),
              const SizedBox(height: 8),
              _buildTagsSection(),
              const SizedBox(height: 8),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  style: const TextStyle(
                    fontSize: 17,
                    color: Colors.white70,
                    height: 1.6,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Empieza a escribir...',
                    hintStyle: TextStyle(color: Colors.white24),
                    border: InputBorder.none,
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                ),
              ),
              // Contador de palabras y caracteres
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  '$_wordCount palabras  ·  $_charCount caracteres',
                  style: const TextStyle(color: Colors.white24, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.note == null) return body;

    return Hero(
      tag: 'note_${widget.note!.id}',
      child: Material(
        color: Colors.transparent,
        child: body,
      ),
    );
  }

  Widget _buildColorPicker() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: AppTheme.noteColors.map((color) {
          final isSelected = _selectedColor.value == color.value;
          return GestureDetector(
            onTap: () => setState(() => _selectedColor = color),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.neonAccent : Colors.transparent,
                  width: 2.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.neonAccent.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_tags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _tags.map((tag) {
              return GestureDetector(
                onTap: () => _removeTag(tag),
                child: GlassContainer(
                  borderRadius: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  blur: 5,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(tag,
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.neonAccent)),
                      const SizedBox(width: 4),
                      const Icon(Icons.close, size: 12, color: Colors.white38),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Añadir etiqueta...',
                  hintStyle: TextStyle(color: Colors.white24, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  prefixIcon: Icon(Icons.tag, size: 16, color: Colors.white38),
                  prefixIconConstraints: BoxConstraints(minWidth: 24, minHeight: 24),
                ),
                onSubmitted: _addTag,
              ),
            ),
          ],
        ),
        const Divider(color: Colors.white10),
      ],
    );
  }
}
