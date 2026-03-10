import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/notes_provider.dart';
import '../widgets/note_card.dart';
import '../widgets/neon_fab.dart';
import '../widgets/glass_container.dart';
import '../theme/app_theme.dart';
import 'edit_note_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(context).animate().fade().slideY(begin: -0.2, end: 0),
            Expanded(
              child: Consumer<NotesProvider>(
                builder: (context, provider, child) {
                  final pinnedNotes = provider.pinnedNotes;
                  final unpinnedNotes = provider.unpinnedNotes;
                  
                  if (provider.allNotes.isEmpty && provider.archivedNotes.isEmpty) {
                    return const Center(
                      child: Text(
                        'Create your first note\nby tapping the + button',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                    );
                  }

                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      if (pinnedNotes.isNotEmpty) ...[
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Text(
                              'Pinned',
                              style: TextStyle(color: AppTheme.neonAccent, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          sliver: _buildNotesGrid(pinnedNotes),
                        ),
                      ],
                      if (unpinnedNotes.isNotEmpty) ...[
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Text(
                              'Others',
                              style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          sliver: _buildNotesGrid(unpinnedNotes),
                        ),
                      ]
                    ],
                  ).animate().fade(duration: 400.ms);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: NeonFab(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditNoteScreen()),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GlassContainer(
        borderRadius: 30.0,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
        child: TextField(
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search notes...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
            icon: Icon(Icons.search, color: AppTheme.neonAccent),
          ),
          onChanged: (value) {
            context.read<NotesProvider>().search(value);
          },
        ),
      ),
    );
  }

  Widget _buildNotesGrid(List notes) {
    return SliverMasonryGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      itemBuilder: (context, index) {
        final note = notes[index];
        return Hero(
          tag: 'note_${note.id}',
          child: Material(
            color: Colors.transparent,
            child: NoteCard(
              note: note,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditNoteScreen(note: note)),
                );
              },
              onLongPress: () {
                _showNoteOptions(context, note);
              },
            ),
          ),
        ).animate().scale(delay: (index * 50).ms, curve: Curves.easeOutBack);
      },
      childCount: notes.length,
    );
  }

  void _showNoteOptions(BuildContext context, note) {
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
              leading: Icon(note.isPinned ? Icons.push_pin_outlined : Icons.push_pin, color: Colors.white),
              title: Text(note.isPinned ? 'Unpin' : 'Pin', style: const TextStyle(color: Colors.white)),
              onTap: () {
                context.read<NotesProvider>().togglePin(note.id);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive, color: Colors.white),
              title: Text(note.isArchived ? 'Unarchive' : 'Archive', style: const TextStyle(color: Colors.white)),
              onTap: () {
                context.read<NotesProvider>().toggleArchive(note.id);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.redAccent),
              title: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
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
