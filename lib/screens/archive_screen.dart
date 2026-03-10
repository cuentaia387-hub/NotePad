import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../providers/notes_provider.dart';
import '../widgets/note_card.dart';
import '../widgets/glass_container.dart';
import '../theme/app_theme.dart';
import 'edit_note_screen.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Archivadas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<NotesProvider>(
        builder: (context, provider, child) {
          final archivedNotes = provider.archivedNotes;

          if (archivedNotes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.archive_outlined,
                    size: 72,
                    color: Colors.white24,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No tienes notas archivadas',
                    style: TextStyle(color: Colors.white38, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Mantén pulsada una nota para archivarla',
                    style: TextStyle(color: Colors.white24, fontSize: 13),
                  ),
                ],
              ).animate().fade(duration: 400.ms),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: MasonryGridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              physics: const BouncingScrollPhysics(),
              itemCount: archivedNotes.length,
              itemBuilder: (context, index) {
                final note = archivedNotes[index];
                return Hero(
                  tag: 'note_${note.id}',
                  child: Material(
                    color: Colors.transparent,
                    child: NoteCard(
                      note: note,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditNoteScreen(note: note),
                          ),
                        );
                      },
                      onLongPress: () {
                        _showOptions(context, note);
                      },
                    ),
                  ),
                ).animate().scale(delay: (index * 50).ms, curve: Curves.easeOutBack);
              },
            ),
          );
        },
      ),
    );
  }

  void _showOptions(BuildContext context, note) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassContainer(
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.unarchive, color: Colors.white),
              title: const Text('Desarchivar', style: TextStyle(color: Colors.white)),
              onTap: () {
                context.read<NotesProvider>().toggleArchive(note.id);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.redAccent),
              title: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                context.read<NotesProvider>().deleteNote(note.id);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
