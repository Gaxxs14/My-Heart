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
    final couple  = Provider.of<CoupleProvider>(context, listen: false);
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
    final couple           = Provider.of<CoupleProvider>(context);
    final todayData        = couple.todayQuestion;
    final question         = todayData?['question'];
    final userHasAnswered  = todayData?['user_answered']   ?? false;
    final partnerHasAnswered = todayData?['partner_answered'] ?? false;
    final userAnswer       = todayData?['user_answer'];
    final partnerAnswer    = todayData?['partner_answer'];
    final isLocked         = todayData?['is_locked_for_user'] ?? false;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.85),
        elevation: 0,
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (b) => AppTheme.loveGradient.createShader(b),
          child: const Text(
            'Daily Sparks ✨',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
              fontFamily: 'Playfair Display',
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_edu_rounded),
            color: AppTheme.primaryRose,
            tooltip: 'Historial de respuestas 📜',
            onPressed: () => _showHistoryBottomSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.casino_rounded),
            color: AppTheme.primaryRose,
            tooltip: 'Girar otra pregunta 🎲',
            onPressed: () => couple.loadTodayQuestion(random: true),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            color: AppTheme.primaryRose,
            tooltip: 'Recargar',
            onPressed: () => couple.loadTodayQuestion(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.softPink.withValues(alpha: 0.5),
              Colors.white,
              AppTheme.softPink.withValues(alpha: 0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: couple.isLoadingQuestion
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppTheme.loveGradient,
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.heroShadow,
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 32),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 800.ms),
                    const SizedBox(height: 16),
                    const Text(
                      'Cargando tu chispa de hoy...',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 100, 20, 100),
                child: Column(
                  children: [
                    // ── Question Card (Hero) ───────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                      decoration: BoxDecoration(
                        gradient: AppTheme.loveGradient,
                        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryRose.withValues(alpha: 0.35),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -10,
                            top: -10,
                            child: Icon(Icons.auto_awesome, color: Colors.white.withValues(alpha: 0.12), size: 100),
                          ),
                          Column(
                            children: [
                              Text(question?['emoji'] ?? '💬', style: const TextStyle(fontSize: 44)),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                ),
                                child: Text(
                                  (question?['category'] ?? 'DEEP').toString().toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                question?['question_text'] ?? '¿Qué es lo que más te gusta de nosotros?',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: () => couple.loadTodayQuestion(random: true),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.casino_rounded, color: Colors.white, size: 14),
                                      SizedBox(width: 6),
                                      Text(
                                        'Girar otra pregunta 🎲',
                                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),

                    const SizedBox(height: 20),

                    // ── Partner's Answer ───────────────────────────────
                    _buildPartnerAnswerCard(
                      partnerHasAnswered: partnerHasAnswered,
                      partnerAnswer: partnerAnswer,
                      isLocked: isLocked,
                      userHasAnswered: userHasAnswered,
                    ).animate(delay: 150.ms).fadeIn(duration: 400.ms).slideY(begin: 0.05),

                    const SizedBox(height: 16),

                    // ── User Answer ────────────────────────────────────
                    if (!userHasAnswered)
                      _buildAnswerInputCard(question?['id'])
                          .animate(delay: 250.ms).fadeIn(duration: 400.ms).slideY(begin: 0.05)
                    else
                      _buildMyAnswerCard(userAnswer)
                          .animate(delay: 250.ms).fadeIn(duration: 400.ms).slideY(begin: 0.05),
                  ],
                ),
              ),
      ),
    );
  }

  // ─── Partner Card ─────────────────────────────────────────────────────────

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
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.blushPink, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(gradient: AppTheme.loveGradient, shape: BoxShape.circle),
                child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 10),
              const Text(
                'Respuesta de tu Pareja',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.deepWine),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (!partnerHasAnswered)
            const Row(
              children: [
                Text('⏳', style: TextStyle(fontSize: 18)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tu pareja aún no ha respondido hoy.',
                    style: TextStyle(color: AppTheme.textMuted, fontStyle: FontStyle.italic, fontSize: 14),
                  ),
                ),
              ],
            )
          else if (!userHasAnswered)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.softPink, AppTheme.blushPink.withValues(alpha: 0.5)],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.lock_rounded, color: AppTheme.primaryRose, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Responde primero para desbloquear lo que contestó tu amor 💕',
                      style: TextStyle(fontSize: 13, color: AppTheme.deepWine, fontWeight: FontWeight.w600, height: 1.4),
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              partnerAnswer ?? 'Sin respuesta',
              style: const TextStyle(fontSize: 16, color: AppTheme.textDark, height: 1.5),
            ),
        ],
      ),
    );
  }

  // ─── Answer Input ─────────────────────────────────────────────────────────

  Widget _buildAnswerInputCard(String? questionId) {
    if (questionId == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.blushPink, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: const BoxDecoration(color: AppTheme.softPink, shape: BoxShape.circle),
                child: const Icon(Icons.edit_note_rounded, color: AppTheme.primaryRose, size: 16),
              ),
              const SizedBox(width: 10),
              const Text(
                'Tu Respuesta',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.deepWine),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _answerController,
            maxLines: 4,
            decoration: const InputDecoration(hintText: 'Escribe tu respuesta sincera aquí...'),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppTheme.loveGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              boxShadow: AppTheme.heroShadow,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isSubmitting ? null : () => _submitAnswer(questionId),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                child: Center(
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          'Enviar y Revelar Respuesta 💖',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── My Answer ────────────────────────────────────────────────────────────

  Widget _buildMyAnswerCard(String? userAnswer) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.blushPink, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: const BoxDecoration(color: Color(0xFFE8F8F1), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_rounded, color: Color(0xFF00C9A7), size: 16),
              ),
              const SizedBox(width: 10),
              const Text(
                'Tu Respuesta ✅',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.deepWine),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            userAnswer ?? '',
            style: const TextStyle(fontSize: 16, color: AppTheme.textDark, height: 1.5),
          ),
        ],
      ),
    );
  }

  void _showHistoryBottomSheet(BuildContext context) {
    final couple = Provider.of<CoupleProvider>(context, listen: false);
    couple.loadAnswerHistory();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Consumer<CoupleProvider>(
          builder: (context, couple, _) {
            final history = couple.questionHistory;

            return DraggableScrollableSheet(
              initialChildSize: 0.75,
              minChildSize: 0.4,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: AppTheme.loveGradient,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.history_edu_rounded, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Historial de Respuestas Reales 📜',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.deepWine,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (history.isEmpty)
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text('💌', style: TextStyle(fontSize: 40)),
                                SizedBox(height: 10),
                                Text(
                                  'Aún no hay respuestas guardadas.\n¡Empiecen a responder preguntas juntos!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.separated(
                            controller: scrollController,
                            itemCount: history.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final item = history[index];
                              final myAns = item['my_answer'];
                              final partnerAns = item['partner_answer'];
                              final partnerHasAns = item['partner_has_answered'] == true || partnerAns != null;

                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF9FA),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: myAns == null && partnerHasAns
                                        ? AppTheme.primaryRose.withOpacity(0.5)
                                        : const Color(0xFFFFE0E8),
                                    width: myAns == null && partnerHasAns ? 1.5 : 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(item['emoji'] ?? '💬', style: const TextStyle(fontSize: 20)),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            item['question_text'] ?? '',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: AppTheme.deepWine,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 20, color: Color(0xFFFFE0E8)),
                                    // My Answer
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Tú: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryRose)),
                                        Expanded(
                                          child: Text(
                                            myAns ?? '(Sin responder aún)',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: myAns != null ? AppTheme.textDark : Colors.grey,
                                              fontStyle: myAns != null ? FontStyle.normal : FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // Partner Answer
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Pareja: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF880E4F))),
                                        Expanded(
                                          child: Text(
                                            partnerAns != null
                                                ? partnerAns
                                                : (partnerHasAns
                                                    ? '🔒 Ya respondió (Desbloquear respondiendo)'
                                                    : '(Sin responder aún)'),
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: partnerAns != null
                                                  ? AppTheme.textDark
                                                  : (partnerHasAns ? AppTheme.primaryRose : Colors.grey),
                                              fontWeight: partnerHasAns && partnerAns == null ? FontWeight.w600 : FontWeight.normal,
                                              fontStyle: partnerAns != null ? FontStyle.normal : FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (myAns == null) ...[
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.primaryRose,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            couple.loadTodayQuestion(questionId: item['question_id']);
                                          },
                                          icon: const Icon(Icons.edit_note_rounded, size: 16, color: Colors.white),
                                          label: const Text(
                                            '✍️ Responder esta pregunta',
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

