import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:home_widget/home_widget.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/couple_provider.dart';
import '../../../core/theme/theme_provider.dart';

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
                    maxLines: 3,
                    maxLength: 120,
                    decoration: const InputDecoration(
                      hintText: 'Ej. Te amo infinito 💕 Que tengas un día hermoso',
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
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                final author = note['author_name'] ?? 'Tú';
                final content = note['content'] ?? '';
                final noteColor = _getNoteColor(note['color']);

                return Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(14),
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
                          GestureDetector(
                            onTap: () => couple.deleteStickyNote(note['id']),
                            child: const Icon(Icons.close_rounded, size: 14, color: Colors.black45),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: Text(
                          content,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF2B2B2B), height: 1.2),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
