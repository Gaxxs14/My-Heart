import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/couple_provider.dart';
import '../../../core/theme/theme_provider.dart';

class PlacesMapScreen extends StatelessWidget {
  const PlacesMapScreen({super.key});

  void _showAddPlaceDialog(BuildContext context) {
    final nameController = TextEditingController();
    final cityController = TextEditingController();
    final noteController = TextEditingController();
    String category = 'restaurant';

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
                      'Nuevo Lugar Especial 📍',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF880E4F)),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Lugar',
                        hintText: 'Ej. Trattoria Bella, Playa del Carmen, Mirador',
                        prefixIcon: Icon(Icons.place_rounded, color: Color(0xFFFF5E7E)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: cityController,
                      decoration: const InputDecoration(
                        labelText: 'Ciudad o Zona',
                        hintText: 'Ej. Centro Histórico, Cancún',
                        prefixIcon: Icon(Icons.location_city_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      decoration: const InputDecoration(
                        labelText: 'Nota o Recuerdo de la cita',
                        hintText: 'Ej. Probamos el mejor vino y nos reímos toda la noche',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Restaurante 🍝'),
                          selected: category == 'restaurant',
                          onSelected: (val) => setModalState(() => category = 'restaurant'),
                        ),
                        ChoiceChip(
                          label: const Text('Café ☕'),
                          selected: category == 'cafe',
                          onSelected: (val) => setModalState(() => category = 'cafe'),
                        ),
                        ChoiceChip(
                          label: const Text('Mirador 🌅'),
                          selected: category == 'viewpoint',
                          onSelected: (val) => setModalState(() => category = 'viewpoint'),
                        ),
                        ChoiceChip(
                          label: const Text('Playa 🏖️'),
                          selected: category == 'beach',
                          onSelected: (val) => setModalState(() => category = 'beach'),
                        ),
                        ChoiceChip(
                          label: const Text('Parque 🌳'),
                          selected: category == 'park',
                          onSelected: (val) => setModalState(() => category = 'park'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (nameController.text.trim().isEmpty) return;

                          final couple = Provider.of<CoupleProvider>(context, listen: false);
                          couple.addPlace(
                            name: nameController.text.trim(),
                            city: cityController.text.trim().isNotEmpty ? cityController.text.trim() : 'Nuestra Ciudad',
                            category: category,
                            note: noteController.text.trim(),
                          );

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('¡Lugar añadido a su mapa romántico! 📍 (+25 XP)')),
                          );
                        },
                        child: const Text('Guardar Lugar (+25 XP)'),
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

  String _getCategoryEmoji(String? category) {
    switch (category) {
      case 'restaurant':
        return '🍝';
      case 'cafe':
        return '☕';
      case 'viewpoint':
        return '🌅';
      case 'beach':
        return '🏖️';
      case 'park':
        return '🌳';
      default:
        return '📍';
    }
  }

  @override
  Widget build(BuildContext context) {
    final couple = Provider.of<CoupleProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);
    final places = couple.places;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Nuestros Lugares 🗺️',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: theme.secondaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: theme.primaryColor,
        onPressed: () => _showAddPlaceDialog(context),
        icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
        label: const Text('Nuevo Lugar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            // Map / Counter Header Card
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: theme.mainGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.3),
                      blurRadius: 15,
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
                      child: const Text('🗺️', style: TextStyle(fontSize: 28)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${places.length} Lugares Inolvidables',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Cada rincón donde su amor ha dejado huella 💕',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Places List
            Expanded(
              child: places.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('📍', style: TextStyle(fontSize: 50)),
                          SizedBox(height: 12),
                          Text('Aún no han registrado lugares', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('Añade sus restaurantes, cafés y viajes favoritos.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 90),
                      itemCount: places.length,
                      itemBuilder: (context, index) {
                        final p = places[index];
                        final dateStr = p['date'] ?? '';
                        final formattedDate = dateStr.isNotEmpty
                            ? DateFormat('dd MMM yyyy').format(DateTime.tryParse(dateStr) ?? DateTime.now())
                            : '';

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
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: theme.softAccentColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(_getCategoryEmoji(p['category']), style: const TextStyle(fontSize: 22)),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p['name'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2B2B2B),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                                        const SizedBox(width: 2),
                                        Text(p['city'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                        if (formattedDate.isNotEmpty) ...[
                                          const Text(' • ', style: TextStyle(color: Colors.grey)),
                                          Text(formattedDate, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                        ],
                                      ],
                                    ),
                                    if (p['note'] != null && p['note'].toString().isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        p['note'],
                                        style: TextStyle(fontSize: 12, color: theme.primaryColor, fontStyle: FontStyle.italic),
                                      ),
                                    ],
                                  ],
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
}
