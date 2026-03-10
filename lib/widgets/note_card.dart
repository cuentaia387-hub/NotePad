import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../theme/app_theme.dart';
import 'glass_container.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const NoteCard({
    Key? key,
    required this.note,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Ahora mismo';
    if (diff.inHours < 1) return 'Hace ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'Hace ${diff.inHours} h';
    if (diff.inDays == 1) return 'Ayer';
    return DateFormat('d MMM', 'es').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: GlassContainer(
        color: note.color.withOpacity(0.18),
        border: Border.all(
          color: note.color.withOpacity(0.45),
          width: 1.5,
        ),
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title row with pin indicator
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    note.title.isNotEmpty ? note.title : 'Sin título',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (note.isPinned) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.push_pin, size: 14, color: AppTheme.neonAccent),
                ],
              ],
            ),
            if (note.content.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                note.content,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white60,
                  height: 1.4,
                ),
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 10),
            // Tags row
            if (note.tags.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: note.tags.take(2).map((tag) {
                  return GlassContainer(
                    borderRadius: 8.0,
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    blur: 5.0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.tag, size: 10, color: AppTheme.neonAccent),
                        const SizedBox(width: 2),
                        Text(tag,
                            style: const TextStyle(
                                fontSize: 10, color: AppTheme.neonAccent)),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
            ],
            // Date
            Text(
              _formatDate(note.modifiedAt),
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
