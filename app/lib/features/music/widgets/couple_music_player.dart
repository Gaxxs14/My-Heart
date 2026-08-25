import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/providers/couple_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';

class CoupleMusicPlayer extends StatelessWidget {
  const CoupleMusicPlayer({super.key});

  static final Map<String, Map<String, String>> _presetSongs = {
    'perfect': {
      'title': 'Perfect',
      'artist': 'Ed Sheeran',
      'lyrics': 'Encontré un amor para mí...\nCariño, simplemente sumérgete y sígueme el paso.\nPorque éramos solo unos niños cuando nos enamoramos,\nsin saber lo que era el amor.\nNo te dejaré ir esta vez.\n\nBebé, bailando en la oscuridad contigo entre mis brazos,\ndescalzos sobre la hierba, escuchando nuestra canción favorita.\nCuando dijiste que te veías hecha un desastre, yo susurré por lo bajo,\npero lo escuchaste: cariño, te ves perfecta esta noche 💕',
    },
    'until i found you': {
      'title': 'Until I Found You',
      'artist': 'Stephen Sanchez',
      'lyrics': 'Solía decir: "Nunca me volveré a enamorar hasta encontrar a la indicada".\nEstaba en la oscuridad hasta que te encontré a ti.\n\nTe cubriré con todo mi amor cuando haga frío.\nAhora te tengo en mis brazos para siempre.\nNunca te dejaré ir, porque eres todo lo que soñé ✨💖',
    },
    'yellow': {
      'title': 'Yellow',
      'artist': 'Coldplay',
      'lyrics': 'Mira las estrellas, mira cómo brillan por ti y por todo lo que haces.\nVine hasta aquí, escribí una canción para ti y se llamaba "Yellow".\n\nTu piel, oh sí, tu piel y tus huesos se convirtieron en algo hermoso.\nSabes que te amo tanto.\nPor ti me desangraría, mira cómo brillas para mí 🌟💛',
    },
    'all of me': {
      'title': 'All of Me',
      'artist': 'John Legend',
      'lyrics': 'Amo todas tus curvas y todos tus bordes, todas tus perfectas imperfecciones.\nDame todo de ti y yo te daré todo de mí.\nEres mi final y mi principio, incluso cuando pierdo estoy ganando.\nPorque te doy todo de mí y tú me das todo de ti 💕🎹',
    },
    'lover': {
      'title': 'Lover',
      'artist': 'Taylor Swift',
      'lyrics': '¿Podemos estar siempre así de cerca para siempre y por siempre?\nMi corazón ha sido prestado y el tuyo ha sido azul.\nTodo está bien si termina bien contigo a mi lado.\n\n¿Puedo ir a donde tú vayas?\n¿Podemos estar siempre así de cerca?\nEres mi, mi, mi... amante y amor eterno 💖',
    },
    'sabes': {
      'title': 'Sabes',
      'artist': 'Reik',
      'lyrics': 'Sabes que cuando te vi no pude respirar,\nque el tiempo se detuvo cuando te escuché hablar.\nSabes que cada día me enamoro más de ti,\nque no imagino un mundo sin verte sonreír.\nEres el sueño más bonito hecho realidad en mi vida 🌹✨',
    },
  };

  void _showLyricsModal(BuildContext context, CoupleProvider couple, ThemeProvider theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isPlaying = couple.isSongPlaying;
            final lyrics = couple.loveSongLyrics.isNotEmpty
                ? couple.loveSongLyrics
                : 'No has agregado la letra en español de esta canción.\n\nToca el botón "Editar Canción" para agregarla o traducirla 🎶';

            return Container(
              height: MediaQuery.of(context).size.height * 0.82,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  // Top Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header with Song Info & Rotating Disc
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          couple.togglePlaySong();
                          setModalState(() {});
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF1E1E24),
                                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                              ),
                              child: Center(
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.primaryRose,
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.favorite, color: Colors.white, size: 12),
                                  ),
                                ),
                              ),
                            ).animate(
                              target: isPlaying ? 1 : 0,
                              onPlay: (c) => isPlaying ? c.repeat() : null,
                            ).rotate(duration: 3000.ms),
                            Icon(
                              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              couple.loveSongTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.deepWine),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              couple.loveSongArtist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, color: AppTheme.primaryRose),
                        tooltip: 'Editar o cambiar canción',
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showChangeSongDialog(context, couple);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Lyrics Header Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.softPink,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.translate_rounded, size: 14, color: AppTheme.primaryRose),
                        SizedBox(width: 6),
                        Text(
                          'Letra Traducida al Español 🇪🇸💖',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryRose),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Scrollable Lyrics View
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9FA),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFFFE0E8)),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          lyrics,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.8,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Bottom Action Buttons
                  if (couple.loveSongUrl != null &&
                      (couple.loveSongUrl!.contains('youtube.com') ||
                          couple.loveSongUrl!.contains('youtu.be') ||
                          couple.loveSongUrl!.contains('spotify.com')))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: couple.loveSongUrl!.contains('spotify.com') ? const Color(0xFF1DB954) : const Color(0xFFFF0000),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () async {
                            try {
                              final uri = Uri.parse(couple.loveSongUrl!);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              }
                            } catch (_) {}
                          },
                          icon: Icon(
                            couple.loveSongUrl!.contains('spotify.com') ? Icons.music_note_rounded : Icons.play_circle_fill_rounded,
                            color: Colors.white,
                          ),
                          label: Text(
                            couple.loveSongUrl!.contains('spotify.com') ? 'Abrir y Escuchar en Spotify 🟢' : 'Abrir y Escuchar en YouTube 🔴',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryRose,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          couple.togglePlaySong();
                          setModalState(() {});
                        },
                        icon: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white),
                        label: Text(
                          isPlaying ? 'Pausar Canción ⏸️' : 'Reproducir Mientras Lees 🎶▶️',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
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

  void _showChangeSongDialog(BuildContext context, CoupleProvider couple) {
    final titleController = TextEditingController(text: couple.loveSongTitle);
    final artistController = TextEditingController(text: couple.loveSongArtist);
    final urlController = TextEditingController(text: couple.loveSongUrl ?? '');
    final lyricsController = TextEditingController(text: couple.loveSongLyrics);
    String? pickedAudioPath;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void checkPresets(String title) {
              final key = title.trim().toLowerCase();
              for (final entry in _presetSongs.entries) {
                if (key.contains(entry.key)) {
                  artistController.text = entry.value['artist']!;
                  lyricsController.text = entry.value['lyrics']!;
                  break;
                }
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                children: const [
                  Icon(Icons.music_note_rounded, color: AppTheme.primaryRose),
                  SizedBox(width: 8),
                  Text('Canción de Pareja 🎵', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sube tu canción favorita y agrega su letra en español para leerla mientras suena 💕',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 14),

                    // Quick romantic presets chips
                    const Text(
                      'Sugerencias populares:',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.deepWine),
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _presetSongs.values.map((p) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: ActionChip(
                              label: Text('${p['title']} - ${p['artist']}'),
                              labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              backgroundColor: AppTheme.softPink,
                              onPressed: () {
                                setModalState(() {
                                  titleController.text = p['title']!;
                                  artistController.text = p['artist']!;
                                  lyricsController.text = p['lyrics']!;
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: titleController,
                      onChanged: (val) => setModalState(() => checkPresets(val)),
                      decoration: const InputDecoration(
                        labelText: 'Título de la Canción',
                        hintText: 'Ej. Perfect, Until I Found You, Sabes',
                        prefixIcon: Icon(Icons.title_rounded, color: AppTheme.primaryRose),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: artistController,
                      decoration: const InputDecoration(
                        labelText: 'Artista o Banda',
                        hintText: 'Ej. Ed Sheeran, Reik, Coldplay',
                        prefixIcon: Icon(Icons.person_rounded, color: AppTheme.primaryRose),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Spanish Lyrics Input
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Letra en Español (Traducida):',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.deepWine),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            checkPresets(titleController.text);
                            if (lyricsController.text.isEmpty) {
                              lyricsController.text =
                                  'Encontré mi amor perfecto en ti...\nCada verso de esta canción me recuerda a nuestra historia de amor 💕';
                            }
                            setModalState(() {});
                          },
                          icon: const Icon(Icons.auto_awesome, size: 14, color: AppTheme.primaryRose),
                          label: const Text('Autocompletar', style: TextStyle(fontSize: 11, color: AppTheme.primaryRose, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: lyricsController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Escribe o pega aquí la letra traducida al español...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
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
                              checkPresets(titleController.text);
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
                    final lyrics = lyricsController.text.trim();

                    if (title.isNotEmpty) {
                      couple.updateLoveSong(
                        title,
                        artist.isNotEmpty ? artist : 'Nuestra Canción',
                        url: audioUrl.isNotEmpty ? audioUrl : null,
                        lyrics: lyrics.isNotEmpty ? lyrics : null,
                      );
                    }
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('¡Canción y letra en español guardadas para los dos! 🎶💖'),
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
        border: Border.all(color: const Color(0xFFFFE0E8), width: 1.2),
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
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryRose,
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

          // Song Info -> Opens Lyrics Modal
          Expanded(
            child: GestureDetector(
              onTap: () => _showLyricsModal(context, couple, theme),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.music_note_rounded, color: AppTheme.primaryRose, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'NUESTRA CANCIÓN',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryRose,
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                      ),
                      const Text(
                        '📜 Ver letra',
                        style: TextStyle(fontSize: 11, color: AppTheme.primaryRose, fontWeight: FontWeight.bold),
                      ),
                    ],
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

