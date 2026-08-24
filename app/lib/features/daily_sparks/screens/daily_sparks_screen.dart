import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers/couple_provider.dart';
import '../../../core/theme/app_theme.dart';

class DailySparksScreen extends StatefulWidget {
  const DailySparksScreen({super.key});

  @override
  State<DailySparksScreen> createState() => _DailySparksScreenState();
}

class _DailySparksScreenState extends State<DailySparksScreen> {
  final _answerController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CoupleProvider>(context, listen: false).loadTodayQuestion();
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _submitAnswer(String questionId) async {
    final text = _answerController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);
    final couple = Provider.of<CoupleProvider>(context, listen: false);
    final success = await couple.answerTodayQuestion(questionId, text);

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      _answerController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Respuesta enviada! +15 XP para Corazoncito 🐾'),
          backgroundColor: AppTheme.primaryRose,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final couple = Provider.of<CoupleProvider>(context);
    final todayData = couple.todayQuestion;
    final question = todayData?['question'];

    final userHasAnswered = todayData?['user_answered'] ?? false;
    final partnerHasAnswered = todayData?['partner_answered'] ?? false;
    final userAnswer = todayData?['user_answer'];
    final partnerAnswer = todayData?['partner_answer'];
    final isLocked = todayData?['is_locked_for_user'] ?? false;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Daily Sparks 💬',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.deepWine,
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.deepWine),
            onPressed: () => couple.loadTodayQuestion(),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF0F3), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: couple.isLoadingQuestion
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryRose))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Question Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: AppTheme.loveGradient,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryRose.withOpacity(0.3),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            question?['emoji'] ?? '💬',
                            style: const TextStyle(fontSize: 40),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'CATEGORÍA: ${(question?['category'] ?? 'DEEP').toString().toUpperCase()}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            question?['question_text'] ?? '¿Qué es lo que más te gusta de nosotros?',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),

                    const SizedBox(height: 24),

                    // Partner's Answer Card (with Reveal Lock!)
                    _buildPartnerAnswerCard(
                      partnerHasAnswered: partnerHasAnswered,
                      partnerAnswer: partnerAnswer,
                      isLocked: isLocked,
                      userHasAnswered: userHasAnswered,
                    ),

                    const SizedBox(height: 20),

                    // User's Answer Input / Display
                    if (!userHasAnswered)
                      _buildAnswerInputCard(question?['id'])
                    else
                      _buildMyAnswerCard(userAnswer),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPartnerAnswerCard({
    required bool partnerHasAnswered,
    required String? partnerAnswer,
    required bool isLocked,
    required bool userHasAnswered,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFE3E8), width: 1.5),
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
            children: [
              const Icon(Icons.favorite_rounded, color: AppTheme.primaryRose, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Respuesta de tu Pareja',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.deepWine),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!partnerHasAnswered)
            const Text(
              '⏳ Tu pareja aún no ha respondido la pregunta de hoy.',
              style: TextStyle(color: AppTheme.textMuted, fontStyle: FontStyle.italic),
            )
          else if (!userHasAnswered)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.softPink.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: const [
                  Icon(Icons.lock_rounded, color: AppTheme.primaryRose),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '🔒 ¡Respuesta Oculta!\nResponde tú primero para desbloquear y leer lo que contestó tu amor.',
                      style: TextStyle(fontSize: 13, color: AppTheme.deepWine, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              partnerAnswer ?? 'Sin respuesta',
              style: const TextStyle(fontSize: 16, color: AppTheme.textDark, height: 1.4),
            ),
        ],
      ),
    );
  }

  Widget _buildAnswerInputCard(String? questionId) {
    if (questionId == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFE3E8), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tu Respuesta:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.deepWine),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _answerController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Escribe tu respuesta sincera aquí...',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : () => _submitAnswer(questionId),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Enviar y Revelar Respuesta 💖'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyAnswerCard(String? userAnswer) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFE3E8), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text(
                'Tu Respuesta',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.deepWine),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            userAnswer ?? '',
            style: const TextStyle(fontSize: 16, color: AppTheme.textDark, height: 1.4),
          ),
        ],
      ),
    );
  }
}
