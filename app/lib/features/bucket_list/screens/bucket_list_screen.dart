import 'dart:math';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/couple_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';

class BucketListScreen extends StatefulWidget {
  const BucketListScreen({super.key});

  @override
  State<BucketListScreen> createState() => _BucketListScreenState();
}

class _BucketListScreenState extends State<BucketListScreen> {
  static final Map<String, Uint8List> _bucketBytesCache = {};
  final List<String> _dateIdeas = [
    'Noche de pizza casera viendo películas con mantitas 🍕🎬',
    'Pícnic sorpresa en el parque con sus snacks favoritos 🧺🍓',
    'Cita de pintura o cerámica juntos con vino 🎨🍷',
    'Caminata nocturna para ver las estrellas y tomar café ☕✨',
    'Cocinar un postre nuevo desde cero juntos 🥞🍓',
    'Día de spa relajante en casa con mascarillas y masajes 🧖‍♀️🧖‍♂️',
    'Hacer un viaje por carretera espontáneo a un pueblo cercano 🚗💨',
    'Sesión de fotos divertida en una librería o cafetería 📸📚',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CoupleProvider>(context, listen: false).loadBucketList();
    });
  }

  void _showDateRouletteDialog() {
    final randomIdea = _dateIdeas[Random().nextInt(_dateIdeas.length)];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: const [
              Icon(Icons.casino_rounded, color: Color(0xFFFF5E7E)),
              SizedBox(width: 8),
              Text('Ruleta de Citas 🎲', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('¿No saben qué hacer hoy? El destino ha elegido:', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFE3E8)),
                ),
                child: Text(
                  randomIdea,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF880E4F)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Girar de nuevo 🔄'),
            ),
            ElevatedButton(
              onPressed: () async {
                final couple = Provider.of<CoupleProvider>(context, listen: false);
                await couple.addBucketItem(randomIdea, category: 'date_night');
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('¡Cita añadida a su Bucket List! 💖')),
                  );
                }
              },
              child: const Text('¡Añadir a la lista!'),
            ),
          ],
        );
      },
    );
  }

  void _showAddItemDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final myName = auth.currentUser?['nickname'] ?? auth.currentUser?['name'] ?? 'Tú';
    String category = 'date_night';

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
                    'Nueva Meta o Cita Soñada 🎯',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF880E4F)),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: '¿Qué sueño o cita quieren cumplir?',
                      hintText: 'Ej. Viajar juntos a París, Noche de cine',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Detalles (opcional)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Cita Romántica 🍷'),
                        selected: category == 'date_night',
                        onSelected: (val) => setModalState(() => category = 'date_night'),
                      ),
                      ChoiceChip(
                        label: const Text('Viaje ✈️'),
                        selected: category == 'travel',
                        onSelected: (val) => setModalState(() => category = 'travel'),
                      ),
                      ChoiceChip(
                        label: const Text('Aventura ⛺'),
                        selected: category == 'adventure',
                        onSelected: (val) => setModalState(() => category = 'adventure'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.trim().isEmpty) return;

                        final couple = Provider.of<CoupleProvider>(context, listen: false);
                        await couple.addBucketItem(
                          titleController.text.trim(),
                          category: category,
                          description: descController.text.trim(),
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('¡Meta creada por $myName guardada! 💖')),
                          );
                        }
                      },
                      child: const Text('Guardar Meta'),
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

  @override
  Widget build(BuildContext context) {
    final couple = Provider.of<CoupleProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);
    final items = couple.bucketList;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Bucket List & Citas 🎯',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: theme.secondaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.casino_rounded),
            tooltip: 'Ruleta de Citas',
            onPressed: _showDateRouletteDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: theme.primaryColor,
        onPressed: _showAddItemDialog,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Nueva Meta', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.softAccentColor.withOpacity(0.5), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: couple.isLoadingBucket
            ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
            : items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🎯', style: TextStyle(fontSize: 60)),
                        const SizedBox(height: 16),
                        const Text(
                          'Su lista de deseos está vacía',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF880E4F)),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Prueba la ruleta de citas o añade sus sueños juntos.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _showDateRouletteDialog,
                          icon: const Icon(Icons.casino_rounded),
                          label: const Text('Girar Ruleta de Citas 🎲'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 90),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isCompleted = item['is_completed'] ?? false;
                      final creatorName = item['creator_name'] ?? item['author_name'] ?? 'Tú';
                      final proofPhoto = item['proof_photo_url']?.toString();

                      Widget? proofImgWidget;
                      if (proofPhoto != null && proofPhoto.isNotEmpty) {
                        if (proofPhoto.startsWith('data:image')) {
                          Uint8List? bytes = _bucketBytesCache[proofPhoto];
                          if (bytes == null) {
                            try {
                              final b64 = proofPhoto.split(',').last;
                              bytes = base64Decode(b64);
                              _bucketBytesCache[proofPhoto] = bytes;
                            } catch (_) {}
                          }
                          if (bytes != null) {
                            proofImgWidget = Image.memory(
                              bytes,
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              gaplessPlayback: true,
                            );
                          }
                        } else if (proofPhoto.startsWith('http')) {
                          proofImgWidget = Image.network(
                            proofPhoto,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                          );
                        } else if (proofPhoto.startsWith('/')) {
                          proofImgWidget = Image.file(
                            File(proofPhoto),
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                          );
                        }
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isCompleted ? const Color(0xFFF1F8E9) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isCompleted ? Colors.green.shade200 : theme.softAccentColor,
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.primaryColor.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (proofImgWidget != null)
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                child: proofImgWidget,
                              ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Checkbox(
                                    value: isCompleted,
                                    activeColor: Colors.green,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    onChanged: (val) async {
                                      final check = val ?? false;
                                      if (check) {
                                        // Ask if they want to attach a photo
                                        final picker = ImagePicker();
                                        final picked = await picker.pickImage(
                                          source: ImageSource.gallery,
                                          maxWidth: 800,
                                          maxHeight: 800,
                                          imageQuality: 75,
                                        );
                                        String? base64Photo;
                                        if (picked != null) {
                                          final bytes = await picked.readAsBytes();
                                          base64Photo = 'data:image/jpeg;base64,${base64Encode(bytes)}';
                                        }
                                        couple.toggleBucketItem(item['id'], true, proofPhotoUrl: base64Photo);
                                      } else {
                                        couple.toggleBucketItem(item['id'], false);
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['title'] ?? '',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                                            color: isCompleted ? Colors.grey : const Color(0xFF2B2B2B),
                                          ),
                                        ),
                                        if (item['description'] != null && item['description'].toString().isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            item['description'],
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isCompleted ? Colors.grey.shade400 : Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 6),
                                        // Creator badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isCompleted ? Colors.green.shade50 : theme.softAccentColor,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '💡 Idea de: $creatorName 💕',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: isCompleted ? Colors.green.shade800 : theme.primaryColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isCompleted)
                                    const Padding(
                                      padding: EdgeInsets.only(left: 4, top: 4),
                                      child: Text('🎉 +50 XP', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
