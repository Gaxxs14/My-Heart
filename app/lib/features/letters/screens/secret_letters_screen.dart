import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/couple_provider.dart';
import '../../../core/theme/app_theme.dart';

class SecretLettersScreen extends StatefulWidget {
  const SecretLettersScreen({super.key});

  @override
  State<SecretLettersScreen> createState() => _SecretLettersScreenState();
}

class _SecretLettersScreenState extends State<SecretLettersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CoupleProvider>(context, listen: false).loadLetters();
    });
  }

  void _showComposeLetterDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    DateTime unlockDate = DateTime.now().add(const Duration(days: 7));

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
                    'Escribir Carta Cápsula del Tiempo 💌',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.deepWine,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título de la carta',
                      hintText: 'Ej. Para leer en nuestro aniversario',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: contentController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Tu carta de amor sincera...',
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Unlock date selector
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: unlockDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (picked != null) {
                        setModalState(() => unlockDate = picked);
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
                          const Icon(Icons.lock_clock_rounded, color: AppTheme.primaryRose),
                          const SizedBox(width: 10),
                          Text('Se desbloqueará el: ${DateFormat('dd MMM yyyy').format(unlockDate)}'),
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
                        if (titleController.text.trim().isEmpty || contentController.text.trim().isEmpty) return;

                        final couple = Provider.of<CoupleProvider>(context, listen: false);
                        await couple.sendSecretLetter(
                          title: titleController.text.trim(),
                          content: contentController.text.trim(),
                          unlockDate: unlockDate,
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('¡Carta sellada en la cápsula del tiempo! 💌🔒')),
                          );
                        }
                      },
                      child: const Text('Sellar Carta con Amor 💌'),
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
    final letters = couple.letters;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Cartas Cápsula del Tiempo 💌',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.deepWine,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryRose,
        onPressed: _showComposeLetterDialog,
        icon: const Icon(Icons.edit_note_rounded, color: Colors.white),
        label: const Text('Escribir Carta', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF0F3), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: couple.isLoadingLetters
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryRose))
            : letters.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('💌', style: TextStyle(fontSize: 60)),
                        const SizedBox(height: 16),
                        const Text(
                          'No hay cartas en la cápsula',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.deepWine),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Escribe una carta hoy que tu pareja solo pueda abrir en una fecha especial.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 90),
                    itemCount: letters.length,
                    itemBuilder: (context, index) {
                      final letter = letters[index];
                      final isUnlocked = letter['is_unlocked'] ?? true;
                      final unlockDateStr = letter['unlock_date'];
                      final unlockFormatted = unlockDateStr != null
                          ? DateFormat('dd MMM yyyy').format(DateTime.tryParse(unlockDateStr) ?? DateTime.now())
                          : '';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFFFE3E8), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryRose.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'De: ${letter['sender_name'] ?? 'Tu pareja'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryRose,
                                    fontSize: 13,
                                  ),
                                ),
                                if (!isUnlocked)
                                  Row(
                                    children: [
                                      const Icon(Icons.lock_clock_rounded, size: 16, color: Colors.orange),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Abre: $unlockFormatted',
                                        style: const TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  )
                                else
                                  const Icon(Icons.mark_email_read_rounded, size: 18, color: Colors.green),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              letter['title'] ?? 'Carta de Amor',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.deepWine,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (!isUnlocked)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF8E1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  '🔒 Esta carta está sellada. Se desbloqueará automáticamente en su fecha programada.',
                                  style: TextStyle(fontSize: 13, color: Colors.brown, fontStyle: FontStyle.italic),
                                ),
                              )
                            else
                              Text(
                                letter['content'] ?? '',
                                style: const TextStyle(fontSize: 15, color: AppTheme.textDark, height: 1.4),
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
