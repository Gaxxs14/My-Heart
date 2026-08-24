import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/couple_provider.dart';
import '../../../core/theme/theme_provider.dart';

class CoupleCalendarScreen extends StatelessWidget {
  const CoupleCalendarScreen({super.key});

  void _showAddEventDialog(BuildContext context) {
    final titleController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
    String eventType = 'date';
    String emoji = '🍷';

    final types = [
      {'type': 'date', 'emoji': '🍷', 'label': 'Cita Romántica'},
      {'type': 'anniversary', 'emoji': '🎂', 'label': 'Aniversario'},
      {'type': 'trip', 'emoji': '✈️', 'label': 'Viaje Juntos'},
      {'type': 'birthday', 'emoji': '🎁', 'label': 'Cumpleaños'},
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
                    'Nuevo Evento o Fecha Especial 📅',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF880E4F)),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Evento',
                      hintText: 'Ej. Cena en la playa, Viaje de aniversario',
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Event Type Chips
                  Wrap(
                    spacing: 8,
                    children: types.map((t) {
                      final isSelected = eventType == t['type'];

                      return ChoiceChip(
                        label: Text('${t['emoji']} ${t['label']}'),
                        selected: isSelected,
                        onSelected: (val) {
                          setModalState(() {
                            eventType = t['type']!;
                            emoji = t['emoji']!;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 14),

                  // Date Picker Button
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                      );
                      if (picked != null) {
                        setModalState(() => selectedDate = picked);
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
                          const Icon(Icons.calendar_month_rounded, color: Color(0xFFFF5E7E)),
                          const SizedBox(width: 10),
                          Text('Fecha: ${DateFormat('dd MMMM yyyy').format(selectedDate)}'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleController.text.trim().isEmpty) return;

                        final couple = Provider.of<CoupleProvider>(context, listen: false);
                        couple.addCalendarEvent(
                          title: titleController.text.trim(),
                          date: selectedDate.toIso8601String().split('T').first,
                          emoji: emoji,
                          type: eventType,
                        );

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('¡Evento guardado en el calendario! 📅💖')),
                        );
                      },
                      child: const Text('Guardar Evento'),
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
    final events = couple.events;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Calendario de Pareja 📅',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: theme.secondaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: theme.primaryColor,
        onPressed: () => _showAddEventDialog(context),
        icon: const Icon(Icons.event_available_rounded, color: Colors.white),
        label: const Text('Nuevo Evento', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.softAccentColor.withOpacity(0.5), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Next Event Countdown Card
            if (events.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: _buildNextEventCountdown(events.first, theme),
              ),
            ],

            // Events List
            Expanded(
              child: events.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('📅', style: TextStyle(fontSize: 50)),
                          SizedBox(height: 12),
                          Text('No hay eventos programados', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('Añade sus próximas citas, viajes o aniversarios.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 90),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final e = events[index];
                        final date = DateTime.tryParse(e['date'] ?? '') ?? DateTime.now();
                        final diffDays = date.difference(DateTime.now()).inDays + 1;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: theme.softAccentColor, width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: theme.primaryColor.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: theme.softAccentColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(e['emoji'] ?? '📅', style: const TextStyle(fontSize: 22)),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e['title'] ?? '',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      DateFormat('EEEE, dd MMMM yyyy').format(date),
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: diffDays <= 7 ? theme.primaryColor : theme.softAccentColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  diffDays <= 0 ? '¡Hoy! 🎉' : 'En $diffDays días',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: diffDays <= 7 ? Colors.white : theme.secondaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextEventCountdown(dynamic event, ThemeProvider theme) {
    final date = DateTime.tryParse(event['date'] ?? '') ?? DateTime.now();
    final diffDays = date.difference(DateTime.now()).inDays + 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: theme.mainGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Text(event['emoji'] ?? '💖', style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PRÓXIMO MOMENTO ESPECIAL',
                  style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  event['title'] ?? '',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  diffDays <= 0 ? '¡Es hoy! Disfrútenlo al máximo 💕' : 'Faltan $diffDays días para celebrarlo ✨',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
