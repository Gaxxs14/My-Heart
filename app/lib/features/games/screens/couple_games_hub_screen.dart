import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers/couple_provider.dart';
import '../../../core/theme/theme_provider.dart';

class CoupleGamesHubScreen extends StatefulWidget {
  const CoupleGamesHubScreen({super.key});

  @override
  State<CoupleGamesHubScreen> createState() => _CoupleGamesHubScreenState();
}

class _CoupleGamesHubScreenState extends State<CoupleGamesHubScreen> {
  int _activeGameIndex = 0; // 0 = Quiz, 1 = Truth or Dare

  // Quiz State
  int _quizStep = 0;
  int _quizScore = 0;
  bool _quizFinished = false;

  final List<Map<String, dynamic>> _quizQuestions = [
    {
      'question': '¿Cuál es mi comida favorita cuando tengo un día pesado?',
      'options': ['Pizza artesanal 🍕', 'Hamburguesa con papas 🍔', 'Sushi delicioso 🍣', 'Un buen postre de chocolate 🍫'],
      'correct': 0,
    },
    {
      'question': '¿Qué es lo primero que me fijo al despertar?',
      'options': ['En darte un beso / mandarte un mensaje 💕', 'En revisar la hora ⏰', 'En tomar un vaso de agua 💧', 'En desayunar café ☕'],
      'correct': 0,
    },
    {
      'question': '¿Cuál sería mi cita de ensueño perfecta?',
      'options': ['Cabaña en la montaña con fogata 🌲🔥', 'Cena elegante a la luz de las velas 🍷✨', 'Día entero de playa y atardecer 🏖️🌅', 'Pícnic y ver películas bajo las estrellas 🎬🧺'],
      'correct': 0,
    },
    {
      'question': '¿Qué película o serie vería mil veces sin cansarme?',
      'options': ['Una comedia romántica clásica 🍿', 'Harry Potter o Marvel ⚡', 'Una serie de drama y suspenso 📺', 'Una película animada de Disney / Pixar 🏰'],
      'correct': 0,
    },
    {
      'question': '¿Cuál es el mejor abrazo que te puedo dar?',
      'options': ['Un abrazo apretado por la espalda 🧸', 'Un abrazo largo en silencio 💕', 'Un abrazo que termine en besos 💋', 'Todos los anteriores 🥰'],
      'correct': 3,
    },
  ];

  // Truth or Dare State
  String _currentCardCategory = 'romantic';
  String _currentCardText = 'Toca el botón para sacar la primera carta de la baraja 🃏';

  final Map<String, List<String>> _truthOrDareCards = {
    'romantic': [
      '¿Qué fue lo primero que pensaste la primera vez que me viste? 💕',
      'Describe el momento exacto en el que sentiste que te estabas enamorando de mí. ✨',
      'Mírame a los ojos durante 60 segundos seguidos sin hablar y luego dame un beso. 👁️💖',
      'Dedícame una canción ahora mismo y dime por qué te recuerda a mí. 🎶',
      'Dime 3 cosas pequeñas de mi personalidad que te vuelven loco/a de amor. 🌸',
    ],
    'fun': [
      'Haz tu mejor imitación de cómo me comporto cuando tengo hambre. 😂',
      'Baila 30 segundos una canción ridícula elegida por tu pareja. 💃🕺',
      'Cuéntame tu momento más vergonzoso de la infancia que nunca le has dicho a nadie. 🙈',
      'Déjame peinarte o hacerte un peinado gracioso por 5 minutos. 💇‍♂️💇‍♀️',
      'Habla con acento extranjero durante las próximas 3 rondas sin reírte. 🌍',
    ],
    'spicy': [
      'Dame un beso en el lugar donde nunca me has besado antes. 🔥💋',
      'Susúrrame al oído tu fantasía o deseo más atrevido con nosotros. 🌶️',
      'Hazme un masaje relajante de cuello y hombros durante 2 minutos. 💆‍♀️💆‍♂️',
      'Elige una prenda de ropa para que tu pareja se la quite en este momento. 🙈🔥',
      'Dime cuál ha sido el beso que más te ha acelerado el corazón de toda nuestra relación. 💓',
    ],
  };

  void _drawCard(String category) {
    final list = _truthOrDareCards[category]!;
    final random = list[Random().nextInt(list.length)];
    setState(() {
      _currentCardCategory = category;
      _currentCardText = random;
    });
  }

  void _answerQuiz(int index) {
    if (index == _quizQuestions[_quizStep]['correct']) {
      _quizScore++;
    }

    if (_quizStep + 1 < _quizQuestions.length) {
      setState(() => _quizStep++);
    } else {
      final couple = Provider.of<CoupleProvider>(context, listen: false);
      if (couple.coupleData != null) {
        couple.coupleData!['pet_xp'] = (couple.coupleData!['pet_xp'] as int) + 30;
        couple.notifyListeners();
      }
      setState(() => _quizFinished = true);
    }
  }

  void _restartQuiz() {
    setState(() {
      _quizStep = 0;
      _quizScore = 0;
      _quizFinished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Sala de Minijuegos 🎲',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: theme.secondaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
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
            const SizedBox(height: 8),

            // Game Selector Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.softAccentColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeGameIndex = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            gradient: _activeGameIndex == 0 ? theme.mainGradient : null,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              '🎯 Quiz de Pareja',
                              style: TextStyle(
                                color: _activeGameIndex == 0 ? Colors.white : Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeGameIndex = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            gradient: _activeGameIndex == 1 ? theme.mainGradient : null,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              '🃏 Cartas & Retos',
                              style: TextStyle(
                                color: _activeGameIndex == 1 ? Colors.white : Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Active Game View
            Expanded(
              child: _activeGameIndex == 0 ? _buildQuizGame(theme) : _buildTruthOrDareGame(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizGame(ThemeProvider theme) {
    if (_quizFinished) {
      final percentage = ((_quizScore / _quizQuestions.length) * 100).toInt();

      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: theme.softAccentColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🏆', style: TextStyle(fontSize: 60)),
                const SizedBox(height: 12),
                Text(
                  '¡Quiz Completado!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.secondaryColor),
                ),
                const SizedBox(height: 8),
                Text(
                  'Compatibilidad: $percentage%',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: theme.primaryColor),
                ),
                Text(
                  'Acertaste $_quizScore de ${_quizQuestions.length} preguntas (+30 XP para la mascota 🐾)',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _restartQuiz,
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text('Jugar de Nuevo'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentQ = _quizQuestions[_quizStep];

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Counter & Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pregunta ${_quizStep + 1} de ${_quizQuestions.length}',
                style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor),
              ),
              Text('Puntos: $_quizScore', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (_quizStep + 1) / _quizQuestions.length,
              backgroundColor: theme.softAccentColor,
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 20),

          // Question Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: theme.softAccentColor, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              currentQ['question'],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.secondaryColor,
                height: 1.3,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Options List
          ...List.generate(currentQ['options'].length, (index) {
            final opt = currentQ['options'][index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: InkWell(
                onTap: () => _answerQuiz(index),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: theme.softAccentColor),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: theme.softAccentColor,
                        child: Text(
                          String.fromCharCode(65 + index),
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.primaryColor),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          opt,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2B2B2B)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTruthOrDareGame(ThemeProvider theme) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Category Selector Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCategoryChip('romantic', '💕 Romántico', Colors.pink, theme),
              _buildCategoryChip('fun', '😂 Divertido', Colors.orange, theme),
              _buildCategoryChip('spicy', '🔥 Atrevido', Colors.redAccent, theme),
            ],
          ),

          const Spacer(),

          // Card Deck Animation
          Container(
            height: 240,
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: theme.mainGradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _currentCardText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),
            ),
          ).animate(key: ValueKey(_currentCardText)).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 300.ms),

          const Spacer(),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              onPressed: () {
                _drawCard(_currentCardCategory);
                final couple = Provider.of<CoupleProvider>(context, listen: false);
                if (couple.coupleData != null) {
                  couple.coupleData!['pet_xp'] = (couple.coupleData!['pet_xp'] as int) + 5;
                  couple.notifyListeners();
                }
              },
              icon: const Icon(Icons.style_rounded, color: Colors.white),
              label: const Text('¡Sacar Otra Carta! 🃏 (+5 XP)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category, String label, Color color, ThemeProvider theme) {
    final isSelected = _currentCardCategory == category;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: color.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? color : Colors.grey,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      onSelected: (_) => _drawCard(category),
    );
  }
}
