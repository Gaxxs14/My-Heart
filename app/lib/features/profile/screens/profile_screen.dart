import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/couple_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../pairing/screens/pairing_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nicknameController = TextEditingController();
  final _partnerNicknameController = TextEditingController();

  final _favSongTitleController = TextEditingController();
  final _favSongArtistController = TextEditingController();
  final _favSongUrlController = TextEditingController();
  final _favSongLyricsController = TextEditingController();

  File? _avatarFile;

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

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _nicknameController.text = auth.currentUser?['nickname'] ?? '';
    _partnerNicknameController.text = auth.partnerUser?['nickname'] ?? '';

    _favSongTitleController.text = auth.currentUser?['favorite_song_title'] ?? '';
    _favSongArtistController.text = auth.currentUser?['favorite_song_artist'] ?? '';
    _favSongUrlController.text = auth.currentUser?['favorite_song_url'] ?? '';
    _favSongLyricsController.text = auth.currentUser?['favorite_song_lyrics'] ?? '';
  }

  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _partnerNicknameController.dispose();
    _favSongTitleController.dispose();
    _favSongArtistController.dispose();
    _favSongUrlController.dispose();
    _favSongLyricsController.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  Future<void> _togglePlayInApp(String? url, {VoidCallback? onStateChange}) async {
    _audioPlayer ??= AudioPlayer();

    if (_isPlaying) {
      await _audioPlayer?.pause();
      if (mounted) {
        setState(() => _isPlaying = false);
      }
      onStateChange?.call();
      return;
    }

    if (url == null || url.isEmpty) return;

    if (mounted) {
      setState(() => _isPlaying = true);
    }
    onStateChange?.call();

    try {
      String playbackUrl = url;
      if (url.contains('youtube.com') || url.contains('youtu.be')) {
        final yt = YoutubeExplode();
        try {
          final videoId = VideoId(url);
          final manifest = await yt.videos.streamsClient.getManifest(videoId);
          final audioStream = manifest.audioOnly.withHighestBitrate();
          playbackUrl = audioStream.url.toString();
        } catch (e) {
          debugPrint('Error extracting YouTube: $e');
        } finally {
          yt.close();
        }
      }

      if (playbackUrl.startsWith('http://') || playbackUrl.startsWith('https://')) {
        await _audioPlayer?.play(UrlSource(playbackUrl));
      } else {
        await _audioPlayer?.play(DeviceFileSource(playbackUrl));
      }

      _audioPlayer?.onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() => _isPlaying = false);
          onStateChange?.call();
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isPlaying = false);
        onStateChange?.call();
      }
    }
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      maxHeight: 400,
      imageQuality: 70,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      setState(() {
        _avatarFile = File(picked.path);
      });

      if (!mounted) return;
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final success = await auth.updateProfile(avatarUrl: base64Image);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? '¡Foto de perfil guardada con éxito! 📸💖' : 'Error al guardar foto en el servidor.',
            ),
            backgroundColor: success ? AppTheme.primaryRose : Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  ImageProvider? _resolveAvatarImage(String? avatarUrl) {
    if (_avatarFile != null) {
      return FileImage(_avatarFile!);
    }
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      if (avatarUrl.startsWith('data:image')) {
        try {
          final b64 = avatarUrl.split(',').last;
          return MemoryImage(base64Decode(b64));
        } catch (_) {}
      } else if (avatarUrl.startsWith('http')) {
        return NetworkImage(avatarUrl);
      } else if (avatarUrl.startsWith('/')) {
        return FileImage(File(avatarUrl));
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final couple = Provider.of<CoupleProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);

    final userName = auth.currentUser?['name'] ?? 'Usuario';
    final userAvatar = auth.currentUser?['avatar_url'];
    final partnerName = auth.partnerUser?['name'] ?? 'Mi Amor';
    final avatarProvider = _resolveAvatarImage(userAvatar);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Perfil & Personalización 🎨',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: theme.secondaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.softAccentColor.withOpacity(0.5), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar & Photo Picker Section
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: theme.mainGradient,
                            image: avatarProvider != null
                                ? DecorationImage(
                                    image: avatarProvider,
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: theme.primaryColor.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: avatarProvider == null
                              ? Center(
                                  child: Text(
                                    userName.isNotEmpty ? userName[0].toUpperCase() : '♥',
                                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickAvatar,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: theme.primaryColor, width: 2),
                              ),
                              child: Icon(Icons.camera_alt_rounded, size: 18, color: theme.primaryColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      userName,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    if (auth.isPaired)
                      Text(
                        'Vinculado a: $partnerName 💕',
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      )
                    else
                      InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const PairingScreen()),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.softAccentColor.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.link_rounded, size: 16, color: theme.primaryColor),
                              const SizedBox(width: 6),
                              Text(
                                'Vincular con mi Pareja 💖',
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Theme Color Picker Section
              Text(
                '🎨 Colores y Tema de la Aplicación',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.secondaryColor),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: theme.softAccentColor),
                ),
                child: Column(
                  children: [
                    _buildThemeOption(
                      title: '💖 Rose Gold & Pink (Clásico)',
                      palette: AppThemePalette.roseGold,
                      gradient: const [Color(0xFFFF5E7E), Color(0xFFFF8E53)],
                      current: theme.currentPalette,
                      onSelect: () => theme.setPalette(AppThemePalette.roseGold),
                    ),
                    const Divider(),
                    _buildThemeOption(
                      title: '🍷 Wine & Velvet (Vino & Oro)',
                      palette: AppThemePalette.wineVelvet,
                      gradient: const [Color(0xFFBA68C8), Color(0xFF7B1FA2)],
                      current: theme.currentPalette,
                      onSelect: () => theme.setPalette(AppThemePalette.wineVelvet),
                    ),
                    const Divider(),
                    _buildThemeOption(
                      title: '🌌 Midnight Love (Azul & Púrpura)',
                      palette: AppThemePalette.midnightLove,
                      gradient: const [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                      current: theme.currentPalette,
                      onSelect: () => theme.setPalette(AppThemePalette.midnightLove),
                    ),
                    const Divider(),
                    _buildThemeOption(
                      title: '🌸 Cherry Blossom (Flor de Cerezo)',
                      palette: AppThemePalette.cherryBlossom,
                      gradient: const [Color(0xFFF48FB1), Color(0xFFFF4081)],
                      current: theme.currentPalette,
                      onSelect: () => theme.setPalette(AppThemePalette.cherryBlossom),
                    ),
                    const Divider(),
                    _buildThemeOption(
                      title: '🌅 Sunset Romance (Atardecer & Coral)',
                      palette: AppThemePalette.sunsetRomance,
                      gradient: const [Color(0xFFFF7043), Color(0xFFFFB74D)],
                      current: theme.currentPalette,
                      onSelect: () => theme.setPalette(AppThemePalette.sunsetRomance),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Nicknames Section
              Text(
                '💕 Apodos Cariñosos',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.secondaryColor),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: theme.softAccentColor),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _nicknameController,
                      decoration: const InputDecoration(
                        labelText: 'Tu Apodo Cariñoso',
                        hintText: 'Ej. Mi Amor, Bebé, Mi Cielo',
                        prefixIcon: Icon(Icons.favorite_border_rounded),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _partnerNicknameController,
                      decoration: const InputDecoration(
                        labelText: 'Apodo de tu Pareja',
                        hintText: 'Ej. Mi Princesa, Mi Rey',
                        prefixIcon: Icon(Icons.favorite_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          final myNick = _nicknameController.text.trim();
                          final partnerNick = _partnerNicknameController.text.trim();

                          if (auth.currentUser != null) {
                            auth.currentUser!['nickname'] = myNick;
                          }
                          if (auth.partnerUser != null) {
                            auth.partnerUser!['nickname'] = partnerNick;
                          }
                          auth.notifyListeners();

                          await auth.updateProfile(nickname: myNick);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('¡Apodos guardados con éxito! 💖'),
                                backgroundColor: AppTheme.primaryRose,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        child: const Text('Guardar Apodos'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 🎵 Personal Favorite Song Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '🎵 Mi Canción Favorita Personal',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.secondaryColor),
                  ),
                  if (_favSongLyricsController.text.isNotEmpty)
                    TextButton.icon(
                      onPressed: () => _showLyricsModal(
                        context,
                        _favSongTitleController.text.isNotEmpty ? _favSongTitleController.text : 'Mi Canción Favorita',
                        _favSongArtistController.text.isNotEmpty ? _favSongArtistController.text : userName,
                        _favSongLyricsController.text,
                        audioUrl: _favSongUrlController.text.isNotEmpty ? _favSongUrlController.text : null,
                      ),
                      icon: const Icon(Icons.lyrics_rounded, size: 16, color: AppTheme.primaryRose),
                      label: const Text('Ver Letra 📜', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryRose)),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Elige la canción que te define para que tu pareja la conozca y lea su letra en español 💕',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: theme.softAccentColor),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Suggestions row
                    const Text(
                      'Sugerencias populares (Autocompletar):',
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
                                setState(() {
                                  _favSongTitleController.text = p['title']!;
                                  _favSongArtistController.text = p['artist']!;
                                  _favSongLyricsController.text = p['lyrics']!;
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: _favSongTitleController,
                      decoration: const InputDecoration(
                        labelText: 'Título de tu Canción',
                        hintText: 'Ej. Perfect, Yellow, All of Me',
                        prefixIcon: Icon(Icons.music_note_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _favSongArtistController,
                      decoration: const InputDecoration(
                        labelText: 'Artista / Cantante',
                        hintText: 'Ej. Ed Sheeran, Coldplay',
                        prefixIcon: Icon(Icons.person_pin_rounded),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Audio picker
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryRose,
                        side: const BorderSide(color: AppTheme.primaryRose),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        minimumSize: const Size(double.infinity, 42),
                      ),
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(type: FileType.audio);
                        if (result != null && result.files.single.path != null) {
                          setState(() {
                            _favSongUrlController.text = result.files.single.path!;
                            if (_favSongTitleController.text.isEmpty) {
                              _favSongTitleController.text = result.files.single.name.replaceAll('.mp3', '');
                            }
                          });
                        }
                      },
                      icon: const Icon(Icons.upload_file_rounded, size: 18),
                      label: Text(
                        _favSongUrlController.text.isNotEmpty ? '✅ Audio seleccionado' : 'Subir archivo de audio (MP3)',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: _favSongUrlController,
                      decoration: const InputDecoration(
                        labelText: 'O enlace de audio (URL)',
                        hintText: 'https://.../cancion.mp3',
                        prefixIcon: Icon(Icons.link_rounded),
                      ),
                    ),
                    const SizedBox(height: 14),

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
                            final key = _favSongTitleController.text.trim().toLowerCase();
                            for (final entry in _presetSongs.entries) {
                              if (key.contains(entry.key)) {
                                setState(() {
                                  _favSongArtistController.text = entry.value['artist']!;
                                  _favSongLyricsController.text = entry.value['lyrics']!;
                                });
                                return;
                              }
                            }
                            if (_favSongLyricsController.text.isEmpty) {
                              setState(() {
                                _favSongLyricsController.text =
                                    'Esta es mi canción favorita en el mundo...\nCada vez que la escucho pienso en nosotros y en lo feliz que me haces 💕';
                              });
                            }
                          },
                          icon: const Icon(Icons.auto_awesome, size: 14, color: AppTheme.primaryRose),
                          label: const Text('Traducir / Autocompletar', style: TextStyle(fontSize: 11, color: AppTheme.primaryRose, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _favSongLyricsController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Escribe aquí la letra traducida al español para que tu pareja entienda qué significa...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                      ),
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryRose,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () async {
                          final title = _favSongTitleController.text.trim();
                          final artist = _favSongArtistController.text.trim();
                          final url = _favSongUrlController.text.trim();
                          final lyrics = _favSongLyricsController.text.trim();

                          if (auth.currentUser != null) {
                            auth.currentUser!['favorite_song_title'] = title;
                            auth.currentUser!['favorite_song_artist'] = artist;
                            auth.currentUser!['favorite_song_url'] = url;
                            auth.currentUser!['favorite_song_lyrics'] = lyrics;
                          }
                          auth.notifyListeners();

                          final ok = await auth.updateProfile(
                            favoriteSongTitle: title,
                            favoriteSongArtist: artist,
                            favoriteSongUrl: url,
                            favoriteSongLyrics: lyrics,
                          );

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(ok ? '¡Tu canción favorita y letra en español han sido guardadas! 🎶💖' : 'Error al guardar canción.'),
                                backgroundColor: ok ? AppTheme.primaryRose : Colors.redAccent,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.save_rounded, color: Colors.white),
                        label: const Text('Guardar Mi Canción Favorita', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),

              // Partner's Favorite Song Card (if set)
              if (auth.partnerUser?['favorite_song_title'] != null &&
                  auth.partnerUser!['favorite_song_title'].toString().isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  '🎵 Canción Favorita de $partnerName 💕',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.secondaryColor),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F3),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFFFD1DC)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryRose,
                        ),
                        child: const Icon(Icons.music_note_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              auth.partnerUser!['favorite_song_title'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.deepWine),
                            ),
                            Text(
                              auth.partnerUser!['favorite_song_artist'] ?? 'Artista desconocido',
                              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryRose,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                        onPressed: () {
                          _showLyricsModal(
                            context,
                            auth.partnerUser!['favorite_song_title'] ?? 'Canción Favorita',
                            auth.partnerUser!['favorite_song_artist'] ?? partnerName,
                            auth.partnerUser!['favorite_song_lyrics'] ?? 'Tu pareja aún no ha colocado la letra en español.',
                            audioUrl: auth.partnerUser!['favorite_song_url'],
                          );
                        },
                        icon: const Icon(Icons.lyrics_rounded, size: 16, color: Colors.white),
                        label: const Text('Ver Letra', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Danger Zone: Delete Account
              Text(
                'Zona de Cuenta',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Eliminar Cuenta y Todos los Datos 🗑️',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.redAccent),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Borra de forma permanente tu usuario, recuerdos y datos de la base de datos sin dejar registros huérfanos.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          _showDeleteAccountDialog(context, auth);
                        },
                        icon: const Icon(Icons.delete_forever_rounded, size: 18),
                        label: const Text('Eliminar Mi Cuenta Permanentemente'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              SizedBox(width: 8),
              Text('¿Eliminar Cuenta? 🗑️', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: const Text(
            'Esta acción es definitiva. Se eliminará tu cuenta y se desvinculará a tu pareja limpiamente sin dejar registros huérfanos.',
            style: TextStyle(fontSize: 13, color: Color(0xFF424242)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close Profile screen
                final success = await auth.deleteAccount();
                if (context.mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cuenta eliminada correctamente.')),
                  );
                }
              },
              child: const Text('Sí, Eliminar Permanentemente', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildThemeOption({
    required String title,
    required AppThemePalette palette,
    required List<Color> gradient,
    required AppThemePalette current,
    required VoidCallback onSelect,
  }) {
    final isSelected = palette == current;

    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: gradient),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
          ],
        ),
      ),
    );
  }

  void _showLyricsModal(BuildContext context, String title, String artist, String lyrics, {String? audioUrl}) {
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
            return Container(
              height: MediaQuery.of(context).size.height * 0.78,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
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
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryRose,
                        ),
                        child: const Icon(Icons.music_note_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.deepWine),
                            ),
                            Text(
                              artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
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
                  const SizedBox(height: 14),
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
                          lyrics.isNotEmpty ? lyrics : 'No se ha proporcionado la letra en español.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.8,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (audioUrl != null && audioUrl.isNotEmpty) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryRose,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          _togglePlayInApp(audioUrl, onStateChange: () {
                            setModalState(() {});
                          });
                        },
                        icon: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white),
                        label: Text(
                          _isPlaying ? 'Pausar Reproducción ⏸️' : 'Reproducir Música en la App 🎶▶️',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryRose,
                        side: const BorderSide(color: AppTheme.primaryRose),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        if (_isPlaying) {
                          _togglePlayInApp(audioUrl);
                        }
                        Navigator.pop(ctx);
                      },
                      child: const Text('Cerrar Letra 💕', style: TextStyle(fontWeight: FontWeight.bold)),
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
}
