import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:home_widget/home_widget.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/couple_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/emoji_reaction_bar.dart';

class StickyNotesBoard extends StatelessWidget {
  const StickyNotesBoard({super.key});

  void _showAddNoteDialog(BuildContext context) {
    final textController = TextEditingController();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final myName = auth.currentUser?['nickname'] ?? auth.currentUser?['name'] ?? 'Tú';
    String selectedColor = 'pink';

    final colors = [
      {'key': 'pink', 'color': const Color(0xFFFFD1DC), 'label': 'Rosa'},
      {'key': 'yellow', 'color': const Color(0xFFFFF9C4), 'label': 'Amarillo'},
      {'key': 'mint', 'color': const Color(0xFFC8E6C9), 'label': 'Menta'},
      {'key': 'lavender', 'color': const Color(0xFFE1BEE7), 'label': 'Lavanda'},
      {'key': 'peach', 'color': const Color(0xFFFFE0B2), 'label': 'Melocotón'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dejar una Notita de Amor 📝',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF880E4F)),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: textController,
                    maxLines: 4,
                    maxLength: 300,
                    decoration: const InputDecoration(
                      hintText: 'Ej. Te amo infinito 💕 Que tengas un día hermoso lleno de sonrisas...',
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Color del Post-it:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: colors.map((c) {
                      final isSelected = selectedColor == c['key'];

                      return GestureDetector(
                        onTap: () => setModalState(() => selectedColor = c['key'] as String),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: c['color'] as Color,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF880E4F) : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                          child: isSelected ? const Icon(Icons.check, size: 20, color: Color(0xFF880E4F)) : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        final content = textController.text.trim();
                        if (content.isEmpty) return;

                        final couple = Provider.of<CoupleProvider>(context, listen: false);
                        couple.addStickyNote(
                          content: content,
                          color: selectedColor,
                          authorName: myName,
                        );

                        // Auto-sync note to home screen widget
                        HomeWidget.saveWidgetData<String>('note_author', '💌 Nota de $myName');
                        HomeWidget.saveWidgetData<String>('note_content', '"$content"');
                        HomeWidget.updateWidget(
                          name: 'StickyNoteWidgetProvider',
                          androidName: 'StickyNoteWidgetProvider',
                        );

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('¡Notita pegada en su muro y actualizada en el Widget! 💕 (+10 XP)')),
                        );
                      },
                      child: const Text('Pegar Notita (+10 XP)'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showNoteDetailModal(BuildContext context, dynamic note) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = auth.currentUser?['id'];
    final currentUserName = auth.currentUser?['nickname'] ?? auth.currentUser?['name'] ?? 'Tú';

    final author = note['author_name'] ?? 'Tú';
    final content = note['content'] ?? '';
    final colorKey = note['color'];
    final noteColor = _getNoteColor(colorKey);
    final createdAtStr = note['created_at'];
    final formattedDate = createdAtStr != null
        ? DateFormat("d 'de' MMMM, yyyy - hh:mm a").format(DateTime.tryParse(createdAtStr) ?? DateTime.now())
        : '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Consumer<CoupleProvider>(
          builder: (context, couple, _) {
            // Find updated note instance in provider
            final currentNote = couple.stickyNotes.firstWhere(
              (n) => n['id'] == note['id'],
              orElse: () => note,
            );

            List<dynamic> reactions = [];
            if (currentNote['reactions'] is List) {
              reactions = currentNote['reactions'];
            }

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: noteColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, -4)),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header: Author, Date & Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.push_pin_rounded, size: 18, color: Color(0xFF880E4F)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'De: $author 💕',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                ],
                              ),
                              if (formattedDate.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(
                                  formattedDate,
                                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.copy_rounded, size: 20, color: Colors.black54),
                              tooltip: 'Copiar texto',
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: content));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('¡Texto copiado al portapapeles! 📋')),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 22, color: Colors.redAccent),
                              tooltip: 'Eliminar notita',
                              onPressed: () {
                                Navigator.pop(ctx);
                                couple.deleteStickyNote(currentNote['id']);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Notita despegada y eliminada.')),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(color: Colors.black12, height: 1),
                    const SizedBox(height: 16),

                    // Full Content Area
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.45),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withOpacity(0.6)),
                      ),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          content,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E1E1E),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Reactions Label
                    const Text(
                      'Reaccionar a esta notita:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF555555),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Interactive Emoji Reaction Bar
                    EmojiReactionBar(
                      reactions: reactions,
                      currentUserId: currentUserId,
                      onReact: (emoji) {
                        couple.reactToStickyNote(
                          currentNote['id'],
                          emoji,
                          currentUserId: currentUserId,
                          currentUserName: currentUserName,
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Close Button
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF880E4F),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cerrar Notita 💕', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getNoteColor(String? colorKey) {
    switch (colorKey) {
      case 'yellow':
        return const Color(0xFFFFF9C4);
      case 'mint':
        return const Color(0xFFC8E6C9);
      case 'lavender':
        return const Color(0xFFE1BEE7);
      case 'peach':
        return const Color(0xFFFFE0B2);
      default:
        return const Color(0xFFFFD1DC);
    }
  }

  @override
  Widget build(BuildContext context) {
    final couple = Provider.of<CoupleProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);
    final notes = couple.stickyNotes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Notitas Adhesivas 💌',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: theme.secondaryColor,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showAddNoteDialog(context),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Nueva Nota', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (notes.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.softAccentColor),
            ),
            child: const Center(
              child: Text(
                'Aún no hay notitas. ¡Deja un mensaje cariñoso para tu pareja! 📝',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          )
        else
          SizedBox(
            height: 136,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                final author = note['author_name'] ?? 'Tú';
                final content = note['content'] ?? '';
                final noteColor = _getNoteColor(note['color']);

                List<dynamic> reactions = [];
                if (note['reactions'] is List) {
                  reactions = note['reactions'];
                }

                // Extract unique emojis for mini preview badge
                final Set<String> uniqueEmojis = {};
                for (final r in reactions) {
                  if (r is Map && r['emoji'] != null) {
                    uniqueEmojis.add(r['emoji'].toString());
                  }
                }

                return GestureDetector(
                  onTap: () => _showNoteDetailModal(context, note),
                  child: Container(
                    width: 210,
                    margin: const EdgeInsets.only(right: 12, bottom: 4),
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: noteColor,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'De: $author 💕',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF424242)),
                            ),
                            const Icon(Icons.touch_app_rounded, size: 14, color: Colors.black38),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Expanded(
                          child: Text(
                            content,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF2B2B2B), height: 1.25, fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Toca para ver completa',
                              style: TextStyle(fontSize: 9, color: Colors.black45, fontStyle: FontStyle.italic),
                            ),
                            if (uniqueEmojis.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  uniqueEmojis.join(' '),
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
