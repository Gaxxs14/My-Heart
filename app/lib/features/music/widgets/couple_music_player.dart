import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/providers/couple_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';

class CoupleMusicPlayer extends StatelessWidget {
  const CoupleMusicPlayer({super.key});

  void _showChangeSongDialog(BuildContext context, CoupleProvider couple) {
    final titleController = TextEditingController(text: couple.loveSongTitle);
    final artistController = TextEditingController(text: couple.loveSongArtist);
    final urlController = TextEditingController(text: couple.loveSongUrl ?? '');
    String? pickedAudioPath;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                children: const [
                  Icon(Icons.music_note_rounded, color: AppTheme.primaryRose),
                  SizedBox(width: 8),
                  Text('Nuestra Canción 🎵', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personaliza su canción especial de amor y reprodúcela en cualquier momento 💕',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título de la Canción',
                        hintText: 'Ej. Perfect, Stand by Me, Te Amo',
                        prefixIcon: Icon(Icons.title_rounded, color: AppTheme.primaryRose),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: artistController,
                      decoration: const InputDecoration(
                        labelText: 'Artista o Banda',
                        hintText: 'Ej. Ed Sheeran, Reik, Camila',
                        prefixIcon: Icon(Icons.person_rounded, color: AppTheme.primaryRose),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Archivo de Audio o Enlace:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.deepWine),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryRose,
                        side: const BorderSide(color: AppTheme.primaryRose),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        minimumSize: const Size(double.infinity, 44),
                      ),
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.audio,
                        );
                        if (result != null && result.files.single.path != null) {
                          setModalState(() {
                            pickedAudioPath = result.files.single.path!;
                            urlController.text = pickedAudioPath!;
                            if (titleController.text.isEmpty || titleController.text == 'Perfect') {
                              titleController.text = result.files.single.name.replaceAll('.mp3', '');
                            }
                          });
                        }
                      },
                      icon: const Icon(Icons.upload_file_rounded, size: 18),
                      label: Text(
                        pickedAudioPath != null ? '✅ Archivo seleccionado' : 'Subir archivo de audio (MP3)',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: urlController,
                      decoration: const InputDecoration(
                        labelText: 'O pega un enlace de audio (URL)',
                        hintText: 'https://.../cancion.mp3',
                        prefixIcon: Icon(Icons.link_rounded, color: AppTheme.primaryRose),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryRose,
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () {
                    final title = titleController.text.trim();
                    final artist = artistController.text.trim();
                    final audioUrl = urlController.text.trim();

                    if (title.isNotEmpty) {
                      couple.updateLoveSong(
                        title,
                        artist.isNotEmpty ? artist : 'Nuestra Canción',
                        url: audioUrl.isNotEmpty ? audioUrl : null,
                      );
                    }
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('¡Canción de amor guardada! Toca el vinilo para escucharla 🎶💖'),
                        backgroundColor: AppTheme.primaryRose,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text('Guardar Canción', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.softAccentColor, width: 1.2),
        boxShadow: AppTheme.cardShadow,
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
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1E1E24),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                  ),
                  child: Center(
                    child: Container(
                      width: 20,
                      height: 20,
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

                // Play / Pause Icon Overlay
                Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          // Song Info
          Expanded(
            child: GestureDetector(
              onTap: () => _showChangeSongDialog(context, couple),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.music_note_rounded, color: AppTheme.primaryRose, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'NUESTRA CANCIÓN',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: theme.primaryColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                      if (isPlaying) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C9A7).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'EN VIVO 🔊',
                            style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF00C9A7)),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.deepWine),
                  ),
                  Text(
                    artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
          ),

          // Edit button
          IconButton(
            icon: const Icon(Icons.edit_rounded, size: 18),
            color: AppTheme.textMuted,
            tooltip: 'Cambiar o subir canción',
            onPressed: () => _showChangeSongDialog(context, couple),
          ),
        ],
      ),
    );
  }
}
