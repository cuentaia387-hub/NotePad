import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/notes_provider.dart';
import '../widgets/note_card.dart';
import '../widgets/neon_fab.dart';
import '../widgets/glass_container.dart';
import '../widgets/glass_toast.dart';
import '../theme/app_theme.dart';
import 'edit_note_screen.dart';
import 'archive_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _activeTagFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context).animate().fade().slideY(begin: -0.2, end: 0),
            _buildSearchBar(context).animate().fade(delay: 100.ms).slideY(begin: -0.1, end: 0),
            if (_activeTagFilter != null) _buildActiveTagFilter(),
            Expanded(
              child: Consumer<NotesProvider>(
                builder: (context, provider, child) {
                  List pinnedNotes = provider.pinnedNotes;
                  List unpinnedNotes = provider.unpinnedNotes;

                  // Apply tag filter if active
                  if (_activeTagFilter != null) {
                    pinnedNotes = pinnedNotes
                        .where((n) => n.tags.contains(_activeTagFilter))
                        .toList();
                    unpinnedNotes = unpinnedNotes
                        .where((n) => n.tags.contains(_activeTagFilter))
                        .toList();
                  }

                  if (pinnedNotes.isEmpty && unpinnedNotes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _activeTagFilter != null
                                ? Icons.label_off_outlined
                                : Icons.note_add_outlined,
                            size: 72,
                            color: Colors.white12,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _activeTagFilter != null
                                ? 'No hay notas con esta etiqueta'
                                : 'Crea tu primera nota\npulsando el botón +',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 16),
                          ),
                        ],
                      ).animate().fade(duration: 400.ms),
                    );
                  }

                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      if (pinnedNotes.isNotEmpty) ...[
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                            child: Row(
                              children: [
                                Icon(Icons.push_pin, size: 14, color: AppTheme.neonAccent),
                                SizedBox(width: 6),
                                Text('FIJADAS',
                                    style: TextStyle(
                                        color: AppTheme.neonAccent,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2)),
                              ],
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          sliver: _buildNotesGrid(pinnedNotes),
                        ),
                      ],
                      if (unpinnedNotes.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                            child: Text(
                              pinnedNotes.isNotEmpty ? 'OTRAS' : 'TODAS LAS NOTAS',
                              style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
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
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const EditNoteScreen(),
              transitionsBuilder: (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveTagFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Row(
        children: [
          GlassContainer(
            borderRadius: 20,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            blur: 10,
            color: AppTheme.neonAccent.withOpacity(0.1),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.tag, size: 14, color: AppTheme.neonAccent),
                const SizedBox(width: 4),
                Text(
                  _activeTagFilter!,
                  style: const TextStyle(
                      color: AppTheme.neonAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _activeTagFilter = null),
                  child: const Icon(Icons.close, size: 14, color: Colors.white54),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text('Filtrado por etiqueta',
              style: TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Builder(
            builder: (context) => GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: GlassContainer(
                borderRadius: 14,
                padding: const EdgeInsets.all(10),
                child: const Icon(Icons.menu, color: Colors.white70, size: 22),
              ),
            ),
          ),
          const Text(
            'Mis Notas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Consumer<NotesProvider>(
            builder: (context, provider, _) => GestureDetector(
              onTap: () => _showSortOptions(context, provider),
              child: GlassContainer(
                borderRadius: 14,
                padding: const EdgeInsets.all(10),
                child: const Icon(Icons.sort, color: Colors.white70, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: GlassContainer(
        borderRadius: 30.0,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
        child: TextField(
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Buscar notas...',
            hintStyle: TextStyle(color: Colors.white38),
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
        return Dismissible(
          key: Key(note.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.delete_outline, color: Colors.redAccent),
                SizedBox(height: 4),
                Text('Eliminar',
                    style: TextStyle(color: Colors.redAccent, fontSize: 11)),
              ],
            ),
          ),
          confirmDismiss: (_) async {
            return await _confirmDelete(context, note.title);
          },
          onDismissed: (_) {
            context.read<NotesProvider>().deleteNote(note.id);
            GlassToast.show(
              context,
              message: 'Nota eliminada',
              icon: Icons.delete_outline,
              iconColor: Colors.redAccent,
            );
          },
          child: Hero(
            tag: 'note_${note.id}',
            child: Material(
              color: Colors.transparent,
              child: NoteCard(
                note: note,
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => EditNoteScreen(note: note),
                      transitionsBuilder: (_, animation, __, child) =>
                          FadeTransition(opacity: animation, child: child),
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  );
                },
                onLongPress: () => _showNoteOptions(context, note),
                onTagTap: (tag) => setState(() => _activeTagFilter = tag),
              ),
            ),
          ),
        ).animate().scale(delay: (index * 50).ms, curve: Curves.easeOutBack);
      },
      childCount: notes.length,
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String title) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => Dialog(
            backgroundColor: Colors.transparent,
            child: GlassContainer(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.delete_outline,
                      color: Colors.redAccent, size: 40),
                  const SizedBox(height: 12),
                  const Text('¿Eliminar nota?',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    title.isNotEmpty ? '"$title"' : 'Esta nota se eliminará permanentemente.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(ctx, false),
                          child: GlassContainer(
                            borderRadius: 16,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: const Center(
                              child: Text('Cancelar',
                                  style: TextStyle(color: Colors.white70)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(ctx, true),
                          child: GlassContainer(
                            borderRadius: 16,
                            color: Colors.red.withOpacity(0.2),
                            border: Border.all(
                                color: Colors.redAccent.withOpacity(0.5)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: const Center(
                              child: Text('Eliminar',
                                  style: TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ) ??
        false;
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        borderRadius: 0,
        blur: 20,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.neonAccent, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.neonAccent.withOpacity(0.3),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.note_alt_outlined,
                          color: AppTheme.neonAccent, size: 28),
                    ),
                    const SizedBox(height: 14),
                    const Text('Bloc de Notas',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Consumer<NotesProvider>(
                      builder: (context, provider, _) => Text(
                        '${provider.allNotes.length} activas  ·  ${provider.archivedNotes.length} archivadas',
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white10),
              _drawerItem(
                context,
                icon: Icons.home_outlined,
                title: 'Inicio',
                onTap: () => Navigator.pop(context),
              ),
              _drawerItem(
                context,
                icon: Icons.archive_outlined,
                title: 'Archivadas',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ArchiveScreen(),
                    ),
                  );
                },
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('v1.1.0',
                    style: TextStyle(color: Colors.white24, fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(BuildContext context,
      {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white60),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
      onTap: onTap,
    );
  }

  void _showSortOptions(BuildContext context, NotesProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassContainer(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text('Ordenar por',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
            ...[
              ('Más reciente primero', SortOption.newest),
              ('Más antiguo primero', SortOption.oldest),
              ('Título A→Z', SortOption.titleAZ),
              ('Título Z→A', SortOption.titleZA),
            ].map((item) => ListTile(
                  leading: Icon(
                    provider.sortOption == item.$2
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: provider.sortOption == item.$2
                        ? AppTheme.neonAccent
                        : Colors.white38,
                    size: 20,
                  ),
                  title: Text(item.$1,
                      style: const TextStyle(color: Colors.white, fontSize: 15)),
                  onTap: () {
                    provider.setSort(item.$2);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
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
              leading: Icon(
                  note.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                  color: Colors.white),
              title: Text(note.isPinned ? 'Desfijar' : 'Fijar arriba',
                  style: const TextStyle(color: Colors.white)),
              onTap: () {
                context.read<NotesProvider>().togglePin(note.id);
                Navigator.pop(context);
                GlassToast.show(
                  context,
                  message: note.isPinned ? 'Nota desfijada' : 'Nota fijada arriba',
                  icon: Icons.push_pin,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined, color: Colors.white),
              title: Text(note.isArchived ? 'Desarchivar' : 'Archivar',
                  style: const TextStyle(color: Colors.white)),
              onTap: () {
                context.read<NotesProvider>().toggleArchive(note.id);
                Navigator.pop(context);
                GlassToast.show(
                  context,
                  message: 'Nota archivada',
                  icon: Icons.archive_outlined,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text('Eliminar',
                  style: TextStyle(color: Colors.redAccent)),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await _confirmDelete(context, note.title);
                if (confirm) {
                  context.read<NotesProvider>().deleteNote(note.id);
                  GlassToast.show(
                    context,
                    message: 'Nota eliminada',
                    icon: Icons.delete_outline,
                    iconColor: Colors.redAccent,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
