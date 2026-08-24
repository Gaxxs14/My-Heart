import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/providers/couple_provider.dart';
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF880E4F)),
                    ),
                    const SizedBox(height: 16),

                    // Photo Picker Button / Preview
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1080);
                        if (picked != null) {
                          setModalState(() {
                            selectedImage = File(picked.path);
                          });
                        }
                      },
                      child: Container(
                        height: 140,
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
                                  Icon(Icons.add_a_photo_rounded, size: 36, color: Color(0xFFFF5E7E)),
                                  SizedBox(height: 6),
                                  Text(
                                    'Toca para subir una foto de su momento 💕',
                                    style: TextStyle(fontSize: 13, color: Color(0xFFFF5E7E), fontWeight: FontWeight.bold),
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
                        prefixIcon: Icon(Icons.place_rounded, color: Color(0xFFFF5E7E)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Date Picker Button
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: memoryDate,
                          firstDate: DateTime(2010),
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
                            const Icon(Icons.calendar_today_rounded, color: Color(0xFFFF5E7E)),
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
                        onPressed: () async {
                          if (titleController.text.trim().isEmpty) return;

                          final couple = Provider.of<CoupleProvider>(context, listen: false);
                          await couple.addMemory(
                            title: titleController.text.trim(),
                            description: descController.text.trim(),
                            memoryDate: memoryDate.toIso8601String().split('T').first,
                            locationName: locationController.text.trim(),
                          );

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('¡Recuerdo y foto guardados para siempre! 💖 (+20 XP)')),
                            );
                          }
                        },
                        child: const Text('Guardar en la Bóveda (+20 XP)'),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Bóveda de Recuerdos 📸',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: theme.secondaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: theme.primaryColor,
        onPressed: () => _showAddMemoryDialog(context),
        icon: const Icon(Icons.add_photo_alternate_rounded, color: Colors.white),
        label: const Text('Nuevo Recuerdo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.softAccentColor.withOpacity(0.5), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: couple.isLoadingMemories
            ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
            : memories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('📸', style: TextStyle(fontSize: 60)),
                        SizedBox(height: 16),
                        Text(
                          'Aún no hay recuerdos guardados',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF880E4F)),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Toca el botón para subir su primera foto y momento especial.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
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

  Widget _buildMemoryCard(dynamic item, ThemeProvider theme) {
    final dateStr = item['memory_date'] ?? '';
    final formattedDate = dateStr.isNotEmpty
        ? DateFormat('dd MMMM yyyy').format(DateTime.tryParse(dateStr) ?? DateTime.now())
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.softAccentColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (item['location_name'] != null && item['location_name'].toString().isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.place_rounded, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            item['location_name'],
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item['title'] ?? '',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.secondaryColor,
                  ),
                ),
                if (item['description'] != null && item['description'].toString().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    item['description'],
                    style: const TextStyle(fontSize: 14, color: Color(0xFF2B2B2B), height: 1.3),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person_pin_rounded, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Guardado por: ${item['author_name'] ?? 'Tú'} 💕',
                      style: const TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
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
