import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:home_widget/home_widget.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/couple_provider.dart';
import '../../../core/theme/app_theme.dart';

class WidgetsStudioScreen extends StatefulWidget {
  const WidgetsStudioScreen({super.key});

  @override
  State<WidgetsStudioScreen> createState() => _WidgetsStudioScreenState();
}

class _WidgetsStudioScreenState extends State<WidgetsStudioScreen> {
  String _customNoteText = '"Te amo más de lo que las palabras pueden decir 💕"';

  final List<String> _quickNotePresets = [
    '"Te amo más de lo que las palabras pueden decir 💕"',
    '"¡Que tengas un día tan hermoso como tú! ☀️"',
    '"Eres mi persona favorita en todo el universo ✨"',
    '"Pensando en ti en cada segundo 🥰"',
    '"Contando los minutos para abrazarte 🍷💖"',
    '"Gracias por hacerme tan feliz todos los días 💌"',
  ];

  void _showEditNoteDialog(String partnerName) {
    final controller = TextEditingController(text: _customNoteText.replaceAll('"', ''));

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                children: const [
                  Icon(Icons.edit_note_rounded, color: AppTheme.primaryRose),
                  SizedBox(width: 8),
                  Text('Personalizar Nota 💌', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Escribe el mensaje de amor que aparecerá en tu Widget de pantalla:',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: controller,
                      maxLines: 3,
                      maxLength: 100,
                      decoration: const InputDecoration(
                        labelText: 'Tu Mensaje de Amor',
                        hintText: 'Ej. Te amo mi vida 💕 Nos vemos pronto',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'O elige una frase romántica:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.deepWine),
                    ),
                    const SizedBox(height: 8),
                    ..._quickNotePresets.map((preset) {
                      final clean = preset.replaceAll('"', '');
                      return InkWell(
                        onTap: () {
                          setModalState(() {
                            controller.text = clean;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              const Icon(Icons.favorite, size: 12, color: AppTheme.primaryRose),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  clean,
                                  style: const TextStyle(fontSize: 11, color: AppTheme.textDark),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
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
                    final text = controller.text.trim();
                    if (text.isNotEmpty) {
                      setState(() {
                        _customNoteText = '"$text"';
                      });
                      // Auto update widget data in background
                      HomeWidget.saveWidgetData<String>('note_author', '💌 Nota de $partnerName');
                      HomeWidget.saveWidgetData<String>('note_content', _customNoteText);
                      HomeWidget.updateWidget(
                        name: 'StickyNoteWidgetProvider',
                        androidName: 'StickyNoteWidgetProvider',
                      );
                    }
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✨ Texto del Widget actualizado con éxito.'),
                        backgroundColor: AppTheme.primaryRose,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text('Guardar Texto', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _pinWidget({
    required BuildContext context,
    required String providerName,
    required Map<String, String> data,
    required String successName,
  }) async {
    try {
      for (final entry in data.entries) {
        await HomeWidget.saveWidgetData<String>(entry.key, entry.value);
      }
      await HomeWidget.updateWidget(
        name: providerName,
        androidName: providerName,
      );
      await HomeWidget.requestPinWidget(
        androidName: providerName,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✨ Toca "Añadir" en tu pantalla para colocar el Widget $successName.'),
            duration: const Duration(seconds: 4),
            backgroundColor: AppTheme.primaryRose,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Para añadirlo: mantén presionado en tu pantalla de inicio > "Widgets" > "My Heart ($successName)"'),
            duration: const Duration(seconds: 4),
            backgroundColor: AppTheme.primaryRose,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final couple = Provider.of<CoupleProvider>(context);

    final userName = auth.currentUser?['nickname'] ?? auth.currentUser?['name'] ?? 'Tú';
    final partnerName = auth.partnerUser?['nickname'] ?? auth.partnerUser?['name'] ?? 'Mi Amor';
    final isPaired = auth.isPaired;

    return Scaffold(
      backgroundColor: AppTheme.softBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.deepWine),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Widgets de Pantalla 📱',
          style: TextStyle(
            color: AppTheme.deepWine,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header description
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFFFE3E8)),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppTheme.softPink,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.widgets_rounded, color: AppTheme.primaryRose, size: 28),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Coloca el amor directamente en la pantalla de tu celular sin abrir la app.',
                      style: TextStyle(fontSize: 13, color: AppTheme.textDark, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Elige tus Widgets para la Pantalla:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppTheme.deepWine,
              ),
            ),

            const SizedBox(height: 16),

            // Widget 1: Love Counter Widget
            _buildWidgetCard(
              context,
              title: '1. Contador de Días de Amor 💕',
              subtitle: 'Contador romántico de días juntos y nombres de la pareja.',
              widgetPreview: _buildLoveCounterWidgetPreview(
                userName,
                partnerName,
                isPaired ? couple.daysTogether : 1,
                isPaired,
              ),
              onAdd: () => _pinWidget(
                context: context,
                providerName: 'LoveCounterWidgetProvider',
                data: {
                  'couple_names': isPaired ? '$userName & $partnerName ♥' : '$userName & Mi Amor ♥',
                  'days_count': isPaired ? '${couple.daysTogether}' : '1',
                  'days_label': 'DÍAS JUNTOS',
                },
                successName: 'Contador de Amor',
              ),
            ),

            const SizedBox(height: 20),

            // Widget 2: Locket Live Photo Widget
            _buildWidgetCard(
              context,
              title: '2. Foto y Momento Locket 📸',
              subtitle: 'Muestra fotos, recuerdos y notas compartidas con tu amor.',
              widgetPreview: _buildLocketWidgetPreview(partnerName),
              onAdd: () => _pinWidget(
                context: context,
                providerName: 'LocketWidgetProvider',
                data: {
                  'locket_title': '📸 $partnerName & Tú',
                  'locket_caption': 'Pensando en ti con amor 💕',
                },
                successName: 'Foto Locket',
              ),
            ),

            const SizedBox(height: 20),

            // Widget 3: Virtual Pet Widget
            _buildWidgetCard(
              context,
              title: '3. Mascota Virtual de Amor 🐾',
              subtitle: 'Tu mascota creciendo en la pantalla de inicio con su nivel.',
              widgetPreview: _buildPetWidgetPreview(couple.petName, couple.petLevel),
              onAdd: () => _pinWidget(
                context: context,
                providerName: 'PetWidgetProvider',
                data: {
                  'pet_name': couple.petName,
                  'pet_emoji': '🐶',
                  'pet_level': 'Nivel ${couple.petLevel} · Amor Puro 💕',
                },
                successName: 'Mascota Virtual',
              ),
            ),

            const SizedBox(height: 20),

            // Widget 4: Sticky Note / Love Note Widget (With Custom Edit Option)
            _buildWidgetCard(
              context,
              title: '4. Nota de Amor / Post-it 💌',
              subtitle: 'Personaliza el texto libremente para que aparezca en tu pantalla.',
              customAction: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryRose,
                  side: const BorderSide(color: AppTheme.primaryRose),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => _showEditNoteDialog(partnerName),
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: const Text('✏️ Cambiar Texto del Post-it', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              widgetPreview: _buildStickyNoteWidgetPreview(partnerName, _customNoteText),
              onAdd: () => _pinWidget(
                context: context,
                providerName: 'StickyNoteWidgetProvider',
                data: {
                  'note_author': '💌 Nota de $partnerName',
                  'note_content': _customNoteText,
                },
                successName: 'Nota de Amor',
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Widget widgetPreview,
    Widget? customAction,
    String buttonLabel = '📌 Añadir a mi Pantalla de Inicio',
    required VoidCallback onAdd,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFFFE3E8), width: 1.2),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.deepWine),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          if (customAction != null) ...[
            const SizedBox(height: 10),
            customAction,
          ],
          const SizedBox(height: 16),

          // Visual Preview Frame
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E24),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: widgetPreview,
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRose,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: onAdd,
              icon: const Icon(Icons.add_to_home_screen_rounded, size: 18, color: Colors.white),
              label: Text(buttonLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoveCounterWidgetPreview(String u1, String u2, int days, bool isPaired) {
    return Container(
      width: 170,
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: AppTheme.loveGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$u1 & $u2 ♥',
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            isPaired ? '$days' : '♥',
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, height: 1.1),
          ),
          Text(
            isPaired ? 'DÍAS JUNTOS' : 'HISTORIA DE AMOR',
            style: const TextStyle(color: Colors.white70, fontSize: 8, letterSpacing: 1.2, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLocketWidgetPreview(String partner) {
    return Container(
      width: 130,
      height: 120,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: AppTheme.loveGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📸 Locket', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('💖', style: TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          Text('Foto de $partner', style: const TextStyle(color: Colors.white70, fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildPetWidgetPreview(String petName, int level) {
    return Container(
      width: 130,
      height: 120,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: AppTheme.loveGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(petName, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          const Text('🐶', style: TextStyle(fontSize: 30)),
          const SizedBox(height: 2),
          Text('Nivel $level 💕', style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStickyNoteWidgetPreview(String partner, String text) {
    return Container(
      width: 160,
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: AppTheme.loveGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('💌 Nota de $partner', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontStyle: FontStyle.italic, height: 1.2),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
