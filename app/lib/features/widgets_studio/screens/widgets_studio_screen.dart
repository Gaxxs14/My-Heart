import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/couple_provider.dart';
import '../../../core/theme/app_theme.dart';

class WidgetsStudioScreen extends StatelessWidget {
  const WidgetsStudioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final couple = Provider.of<CoupleProvider>(context);

    final userName = auth.currentUser?['nickname'] ?? auth.currentUser?['name'] ?? 'Tú';
    final partnerName = auth.partnerUser?['nickname'] ?? auth.partnerUser?['name'] ?? 'Mi Amor';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Widgets de Inicio 📱',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.deepWine,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF0F3), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
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
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryRose.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
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
                        'Lleva el amor a la pantalla principal de tu teléfono sin abrir la app.',
                        style: TextStyle(fontSize: 13, color: AppTheme.textDark, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Elige un Widget para tu Pantalla:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.deepWine,
                    ),
              ),

              const SizedBox(height: 16),

              // Widget 1: Love Counter Widget Preview (2x2 / 4x2)
              _buildWidgetCard(
                context,
                title: '1. Widget Contador de Amor 💕',
                subtitle: 'Muestra sus días juntos y la foto de ambos siempre visible.',
                widgetPreview: _buildLoveCounterWidgetPreview(userName, partnerName, couple.daysTogether),
                onAdd: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('💡 Para añadirlo en Android: mantén presionado en tu pantalla de inicio > "Widgets" > "My Heart"'),
                      duration: Duration(seconds: 4),
                      backgroundColor: AppTheme.primaryRose,
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Widget 2: Locket Live Photo Widget Preview (2x2)
              _buildWidgetCard(
                context,
                title: '2. Widget Foto en Vivo (Locket) 📸',
                subtitle: 'Cada foto que tu pareja te mande aparecerá al instante en tu celular.',
                widgetPreview: _buildLocketWidgetPreview(partnerName),
                onAdd: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('💡 Mantén presionado en tu pantalla de inicio > Widgets > My Heart (Locket)'),
                      duration: Duration(seconds: 4),
                      backgroundColor: AppTheme.primaryRose,
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Widget 3: Daily Spark Question Widget Preview (4x2)
              _buildWidgetCard(
                context,
                title: '3. Widget Pregunta del Día 💬',
                subtitle: 'Lee y responde la chispa diaria directamente desde el inicio.',
                widgetPreview: _buildDailySparkWidgetPreview(couple),
                onAdd: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('💡 Mantén presionado en tu pantalla de inicio > Widgets > My Heart (Sparks)'),
                      duration: Duration(seconds: 4),
                      backgroundColor: AppTheme.primaryRose,
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Widget widgetPreview,
    required VoidCallback onAdd,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFFFE3E8), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryRose.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.deepWine),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
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
                backgroundColor: AppTheme.softPink,
                foregroundColor: AppTheme.deepWine,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: onAdd,
              icon: const Icon(Icons.add_to_home_screen_rounded, size: 18),
              label: const Text('Cómo Añadir al Celular', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoveCounterWidgetPreview(String user, String partner, int days) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.loveGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$user & $partner',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const Icon(Icons.favorite, color: Colors.white, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$days',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w900,
              fontFamily: 'Playfair Display',
            ),
          ),
          const Text(
            'DÍAS ENAMORADOS',
            style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLocketWidgetPreview(String partner) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C34),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 12,
                backgroundColor: AppTheme.primaryRose,
                child: Text('♥', style: TextStyle(color: Colors.white, fontSize: 10)),
              ),
              const SizedBox(width: 8),
              Text(
                'De: $partner',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              const Text('Ahora mismo', style: TextStyle(color: Colors.white54, fontSize: 9)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_camera_rounded, color: Colors.white70, size: 28),
                  SizedBox(height: 4),
                  Text('Foto compartida en vivo 💕', style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailySparkWidgetPreview(CoupleProvider couple) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text('✨', style: TextStyle(fontSize: 16)),
              SizedBox(width: 6),
              Text(
                'Pregunta de Hoy',
                style: TextStyle(color: AppTheme.deepWine, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            couple.todayQuestion?['question']?['question_text'] ?? '¿Cuál fue el momento en que supiste que te gustaba?',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppTheme.textDark, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.softPink,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('Toca para responder', style: TextStyle(fontSize: 10, color: AppTheme.primaryRose, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
