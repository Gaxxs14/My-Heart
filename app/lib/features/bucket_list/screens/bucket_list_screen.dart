import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/couple_provider.dart';
import '../../../core/theme/app_theme.dart';

class BucketListScreen extends StatefulWidget {
  const BucketListScreen({super.key});

  @override
  State<BucketListScreen> createState() => _BucketListScreenState();
}

class _BucketListScreenState extends State<BucketListScreen> {
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
              Icon(Icons.casino_rounded, color: AppTheme.primaryRose),
              SizedBox(width: 8),
              Text('Ruleta de Citas 🎲', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('¿No saben qué hacer hoy? El destino ha elegido:', style: TextStyle(color: AppTheme.textMuted)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.softPink.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryRose.withOpacity(0.4)),
                ),
                child: Text(
                  randomIdea,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.deepWine),
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
                  Text(
                    'Nueva Meta o Deseo 🎯',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.deepWine,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: '¿Qué sueño o cita quieren cumplir?',
                      hintText: 'Ej. Viajar juntos a París, Adoptar un perrito',
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
    final items = couple.bucketList;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Bucket List & Citas 🎯',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.deepWine,
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.casino_rounded, color: AppTheme.primaryRose),
            tooltip: 'Ruleta de Citas',
            onPressed: _showDateRouletteDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryRose,
        onPressed: _showAddItemDialog,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Nueva Meta', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF0F3), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: couple.isLoadingBucket
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryRose))
            : items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🎯', style: TextStyle(fontSize: 60)),
                        const SizedBox(height: 16),
                        const Text(
                          'Su lista de deseos está vacía',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.deepWine),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Prueba la ruleta de citas o añade sus sueños juntos.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.textMuted),
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

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isCompleted ? const Color(0xFFF1F8E9) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isCompleted ? Colors.green.shade200 : const Color(0xFFFFE3E8),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: isCompleted,
                              activeColor: Colors.green,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              onChanged: (val) {
                                couple.toggleBucketItem(item['id'], val ?? false);
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
                                      color: isCompleted ? Colors.grey : AppTheme.textDark,
                                    ),
                                  ),
                                  if (item['description'] != null && item['description'].toString().isNotEmpty)
                                    Text(
                                      item['description'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isCompleted ? Colors.grey.shade400 : AppTheme.textMuted,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (isCompleted)
                              const Text('🎉 +50 XP', style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
