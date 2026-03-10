import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';

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
  late String _currentTag;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _selectedColor = widget.note?.color ?? AppTheme.noteColors[0];
    _currentTag = widget.note?.tags.isNotEmpty == true ? widget.note!.tags.first : '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    
    if (title.isEmpty && content.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final provider = context.read<NotesProvider>();
    final tags = _currentTag.isNotEmpty ? [_currentTag] : <String>[];

    if (widget.note == null) {
      provider.addNote(title, content, _selectedColor, tags);
    } else {
      provider.updateNote(widget.note!.id, title, content, _selectedColor, tags);
    }
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final body = Scaffold(
      backgroundColor: AppTheme.pureBlack,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: AppTheme.neonAccent),
            onPressed: _saveNote,
          )
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
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                decoration: const InputDecoration(
                  hintText: 'Title',
                  hintStyle: TextStyle(color: Colors.white30),
                  border: InputBorder.none,
                ),
                maxLines: null,
              ),
              const SizedBox(height: 8),
              _buildColorPicker(),
              const SizedBox(height: 16),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Start typing...',
                    hintStyle: TextStyle(color: Colors.white30),
                    border: InputBorder.none,
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
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
            onTap: () {
              setState(() {
                _selectedColor = color;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.neonAccent : Colors.transparent,
                  width: 2,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: AppTheme.neonAccent.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ] : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
