import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers/couple_provider.dart';
import '../../../core/theme/theme_provider.dart';

class CoupleMusicPlayer extends StatelessWidget {
  const CoupleMusicPlayer({super.key});

  void _showChangeSongDialog(BuildContext context, CoupleProvider couple) {
    final titleController = TextEditingController(text: couple.loveSongTitle);
    final artistController = TextEditingController(text: couple.loveSongArtist);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: const [
              Icon(Icons.music_note_rounded, color: Color(0xFFFF5E7E)),
              SizedBox(width: 8),
              Text('Nuestra Canción 🎵', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Elige la canción especial que representa su historia de amor 💕',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Título de la Canción',
                  hintText: 'Ej. Perfect, Stand by Me, Thinking Out Loud',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: artistController,
                decoration: const InputDecoration(
                  labelText: 'Artista / Banda',
                  hintText: 'Ej. Ed Sheeran, Reik, Morat',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty) {
                  couple.updateLoveSong(
                    titleController.text.trim(),
                    artistController.text.trim().isNotEmpty ? artistController.text.trim() : 'Nuestra Canción',
                  );
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('¡Canción de amor actualizada! 🎶💖')),
                );
              },
              child: const Text('Guardar Canción'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final couple = Provider.of<CoupleProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);

    final isPlaying = couple.isSongPlaying;
    final title = couple.loveSongTitle;
    final artist = couple.loveSongArtist;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.softAccentColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Vinyl Record with Rotation Animation
          GestureDetector(
            onTap: couple.togglePlaySong,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1E1E24),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                  ),
                  child: Center(
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.primaryColor,
                      ),
                      child: const Center(
                        child: Icon(Icons.favorite, color: Colors.white, size: 10),
                      ),
                    ),
                  ),
                ).animate(
                  target: isPlaying ? 1 : 0,
                  onPlay: (c) => isPlaying ? c.repeat() : null,
                ).rotate(duration: 3000.ms),

                // Play icon overlay if paused
                if (!isPlaying)
                  const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Song Info
          Expanded(
            child: GestureDetector(
              onTap: () => _showChangeSongDialog(context, couple),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: theme.secondaryColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (isPlaying)
                        const Icon(Icons.graphic_eq_rounded, size: 14, color: Colors.green),
                    ],
                  ),
                  Text(
                    artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          // Controls
          IconButton(
            icon: Icon(
              isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
              color: theme.primaryColor,
              size: 34,
            ),
            onPressed: couple.togglePlaySong,
          ),
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, color: Colors.grey, size: 22),
            tooltip: 'Cambiar Canción',
            onPressed: () => _showChangeSongDialog(context, couple),
          ),
        ],
      ),
    );
  }
}
