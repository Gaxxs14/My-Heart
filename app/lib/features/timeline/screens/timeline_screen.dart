import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/providers/couple_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CoupleProvider>(context, listen: false).loadMemories();
    });
  }

  void _showAddMemoryDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final locationController = TextEditingController();
    DateTime memoryDate = DateTime.now();
    File? selectedImage;
    bool isSaving = false;

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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Guardar un Recuerdo con Foto 📸',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.deepWine),
                    ),
                    const SizedBox(height: 16),

                    // Photo Picker Button / Preview
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 800,
                          maxHeight: 800,
                          imageQuality: 75,
                        );
                        if (picked != null) {
                          setModalState(() {
                            selectedImage = File(picked.path);
                          });
                        }
                      },
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F3),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFFFE3E8), width: 1.5),
                          image: selectedImage != null
                              ? DecorationImage(
                                  image: FileImage(selectedImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: selectedImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.add_a_photo_rounded, size: 36, color: AppTheme.primaryRose),
                                  SizedBox(height: 6),
                                  Text(
                                    'Toca para subir una foto de su momento 💕',
                                    style: TextStyle(fontSize: 13, color: AppTheme.primaryRose, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título del momento',
                        hintText: 'Ej. Primer viaje a la playa',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: '¿Qué pasó ese día especial?',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Lugar (ej. Cancún, Nuestro café favorito)',
                        prefixIcon: Icon(Icons.place_rounded, color: AppTheme.primaryRose),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Date Picker Button
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: memoryDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setModalState(() {
                            memoryDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFFFE3E8)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, color: AppTheme.primaryRose),
                            const SizedBox(width: 10),
                            Text('Fecha: ${DateFormat('dd MMM yyyy').format(memoryDate)}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryRose,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: isSaving
                            ? null
                            : () async {
                                if (titleController.text.trim().isEmpty) return;

                                setModalState(() => isSaving = true);

                                List<String> photoUrls = [];
                                if (selectedImage != null) {
                                  final bytes = await selectedImage!.readAsBytes();
                                  photoUrls.add('data:image/jpeg;base64,${base64Encode(bytes)}');
                                }

                                final couple = Provider.of<CoupleProvider>(context, listen: false);
                                await couple.addMemory(
                                  title: titleController.text.trim(),
                                  description: descController.text.trim(),
                                  memoryDate: memoryDate.toIso8601String().split('T').first,
                                  locationName: locationController.text.trim(),
                                  photoUrls: photoUrls,
                                );

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('¡Recuerdo y foto guardados para siempre! 💖 (+20 XP)'),
                                      backgroundColor: AppTheme.primaryRose,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                        child: isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Text('Guardar en la Bóveda (+20 XP)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  @override
  Widget build(BuildContext context) {
    final couple = Provider.of<CoupleProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);
    final memories = couple.memories;

    return Scaffold(
      backgroundColor: AppTheme.softBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Bóveda de Recuerdos 📸',
          style: TextStyle(
            color: AppTheme.deepWine,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryRose,
        onPressed: () => _showAddMemoryDialog(context),
        icon: const Icon(Icons.add_photo_alternate_rounded, color: Colors.white),
        label: const Text('Nuevo Recuerdo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: couple.isLoadingMemories
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryRose))
            : memories.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: const BoxDecoration(
                              color: AppTheme.softPink,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.photo_library_outlined, size: 54, color: AppTheme.primaryRose),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Su Álbum de Recuerdos está vacío ✨',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.deepWine),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Toca el botón "+ Nuevo Recuerdo" para subir su primera foto y guardar este momento especial.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 90),
                    itemCount: memories.length,
                    itemBuilder: (context, index) {
                      final item = memories[index];
                      return _buildMemoryCard(item, theme);
                    },
                  ),
      ),
    );
  }

  static final Map<String, Uint8List> _memoryBytesCache = {};

  Widget? _buildMemoryImage(dynamic photoUrls) {
    String? url;
    if (photoUrls is List && photoUrls.isNotEmpty) {
      url = photoUrls.first?.toString();
    } else if (photoUrls is String && photoUrls.isNotEmpty) {
      if (photoUrls.startsWith('[')) {
        try {
          final list = jsonDecode(photoUrls) as List;
          if (list.isNotEmpty) url = list.first?.toString();
        } catch (_) {}
      } else {
        url = photoUrls;
      }
    }

    if (url == null || url.isEmpty) return null;

    Widget imageWidget;
    if (url.startsWith('data:image')) {
      Uint8List? bytes = _memoryBytesCache[url];
      if (bytes == null) {
        try {
          final b64 = url.split(',').last;
          bytes = base64Decode(b64);
          _memoryBytesCache[url] = bytes;
        } catch (_) {}
      }

      if (bytes == null) return null;

      imageWidget = Image.memory(
        bytes,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      );
    } else if (url.startsWith('http')) {
      imageWidget = Image.network(
        url,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      );
    } else if (url.startsWith('/')) {
      imageWidget = Image.file(
        File(url),
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      );
    } else {
      return null;
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: imageWidget,
    );
  }

  Widget _buildMemoryCard(dynamic item, ThemeProvider theme) {
    final dateStr = item['memory_date'] ?? '';
    final formattedDate = dateStr.isNotEmpty
        ? DateFormat('dd MMMM yyyy').format(DateTime.tryParse(dateStr) ?? DateTime.now())
        : '';

    final imageWidget = _buildMemoryImage(item['photo_urls']);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFE3E8), width: 1.2),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageWidget != null) imageWidget,
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        color: AppTheme.primaryRose,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (item['location_name'] != null && item['location_name'].toString().isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.place_rounded, size: 14, color: AppTheme.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            item['location_name'],
                            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.deepWine,
                  ),
                ),
                if (item['description'] != null && item['description'].toString().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    item['description'],
                    style: const TextStyle(fontSize: 14, color: AppTheme.textDark, height: 1.3),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.favorite, size: 14, color: AppTheme.primaryRose),
                    const SizedBox(width: 6),
                    Text(
                      'Guardado por: ${item['author_name'] ?? 'Tú'} 💕',
                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
