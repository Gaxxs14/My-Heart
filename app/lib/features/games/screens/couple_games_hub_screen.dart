import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers/couple_provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/app_theme.dart';

class CoupleGamesHubScreen extends StatefulWidget {
  const CoupleGamesHubScreen({super.key});

  @override
  State<CoupleGamesHubScreen> createState() => _CoupleGamesHubScreenState();
}

class _CoupleGamesHubScreenState extends State<CoupleGamesHubScreen> with TickerProviderStateMixin {
  int _activeGameIndex = 0; // 0 = Quiz, 1 = Truth/Dare, 2 = Love Wheel, 3 = This or That

  // ─────────────────────────────────────────────────────────────────────────────
  // 1. QUIZ DE PAREJA STATE & DATA
  // ─────────────────────────────────────────────────────────────────────────────
  String _quizCategory = 'romance';
  int _quizStep = 0;
  int _quizScore = 0;
  bool _quizFinished = false;
  final List<String> _userAnswers = [];

  final Map<String, List<Map<String, dynamic>>> _quizCategoriesData = {
    'romance': [
      {
        'question': '¿Qué fue lo primero que pensé el día que te vi por primera vez?',
        'options': ['"Qué persona tan hermosa y especial" 💕', '"Me encanta su sonrisa y mirada" ✨', '"Tengo que hablarle y conocerle ya" 😍', '"Será alguien muy importante en mi vida" 💖'],
      },
      {
        'question': '¿Cuál es mi mayor lenguaje de amor contigo?',
        'options': ['Abrazos, caricias y besos largos 🫂', 'Palabras bonitas y cartas de amor 💌', 'Tiempo de calidad a solas ⏳', 'Detalles y regalitos sorpresa 🎁'],
      },
      {
        'question': '¿Cuál sería nuestra cita de aniversario soñada?',
        'options': ['Cabaña en la montaña con fogata y vino 🌲🔥', 'Cena elegante a la luz de las velas 🍷✨', 'Viaje a la playa para ver el atardecer 🏖️🌅', 'Pícnic nocturno viendo las estrellas 🧺🌌'],
      },
      {
        'question': '¿Qué es lo que más me tranquiliza cuando estoy estresado/a?',
        'options': ['Que me des un abrazo apretado en silencio 🧸', 'Que me escuches y me des ánimos 💕', 'Comer algo rico juntos 🍕', 'Un masaje relajante en la espalda 💆'],
      },
      {
        'question': '¿Cuál de estos recuerdos juntos atesoro más?',
        'options': ['Nuestro primer beso inolvidable 💋', 'La primera vez que nos reímos hasta llorar 😂', 'Nuestro primer viaje o salida especial ✈️', 'Cada noche que pasamos juntos hablando 🌙'],
      },
    ],
    'food_habits': [
      {
        'question': '¿Cuál es mi comida favorita para consentirme?',
        'options': ['Pizza artesanal o hamburguesa 🍕🍔', 'Sushi delicioso 🍣', 'Un buen postre o helado de chocolate 🍫🍦', 'Comida casera calientita 🍲'],
      },
      {
        'question': '¿Qué es lo primero que hago nada más despertar?',
        'options': ['Darle un beso o escribirle a mi amor 💕', 'Revisar la hora y redes sociales 📱', 'Tomar agua o café ☕', 'Quedarme 5 minutos más en la cama 🛌'],
      },
      {
        'question': 'Si tuviéramos un día libre sin planes, ¿qué preferiría hacer?',
        'options': ['Maratón de películas y comer en la cama 🎬🍿', 'Salir a caminar y explorar cafeterías ☕🚶', 'Cocinar algo rico juntos desde cero 👩‍🍳👨‍🍳', 'Día de compras y pasear 🛍️'],
      },
      {
        'question': '¿Qué tipo de música o ambiente me pone de mejor humor?',
        'options': ['Canciones románticas acústicas 🎶', 'Música alegre para bailar y cantar 💃🕺', 'Rock / Pop nostálgico 🎸', 'Sonidos relajantes o lofi 🎧'],
      },
    ],
    'spicy': [
      {
        'question': '¿Dónde me encanta más recibir un beso tuyo?',
        'options': ['En el cuello con suavidad 🔥', 'En los labios de forma apasionada 💋', 'En la frente con ternura 🥰', 'En la mejilla con abrazo apretado 💕'],
      },
      {
        'question': '¿Qué es lo que más me atrae y enciende de ti?',
        'options': ['Tu mirada coqueta y sonrisa traviesa 😉', 'Tu perfume y aroma natural 🌸', 'Tu manera de abrazarme y tocarme 🫂', 'Toda tu personalidad y cuerpo completo 🔥'],
      },
      {
        'question': '¿Cuál de estos planes íntimos preferiría esta noche?',
        'options': ['Masaje con aceites y velas aromáticas 🕯️💆', 'Noche de besos y caricias sin prisa 💋', 'Ver una película romántica muy pegaditos 🍿', 'Una sorpresa atrevida e inolvidable 🙈🔥'],
      },
    ],
  };

  List<Map<String, dynamic>> get _currentQuizQuestions => _quizCategoriesData[_quizCategory] ?? _quizCategoriesData['romance']!;

  void _answerQuiz(int index) {
    final list = _currentQuizQuestions;
    _userAnswers.add(list[_quizStep]['options'][index]);
    _quizScore += 25;

    if (_quizStep + 1 < list.length) {
      setState(() => _quizStep++);
    } else {
      final couple = Provider.of<CoupleProvider>(context, listen: false);
      couple.addPetXp(30);
      setState(() => _quizFinished = true);
    }
  }

  void _restartQuiz(String category) {
    setState(() {
      _quizCategory = category;
      _quizStep = 0;
      _quizScore = 0;
      _userAnswers.clear();
      _quizFinished = false;
    });
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 2. VERDAD O RETO (TRUTH OR DARE) STATE & DATA
  // ─────────────────────────────────────────────────────────────────────────────
  String _currentCardCategory = 'romantic';
  String _currentCardText = 'Toca el botón para sacar la primera carta de la baraja 🃏';

  final Map<String, List<String>> _truthOrDareCards = {
    'romantic': [
      '¿Qué fue lo primero que pensaste la primera vez que me viste? 💕',
      'Describe el momento exacto en el que sentiste que te estabas enamorando de mí. ✨',
      'Mírame a los ojos durante 60 segundos seguidos sin hablar y luego dame un beso. 👁️💖',
      'Dedícame una canción ahora mismo y dime por qué te recuerda a mí. 🎶',
      'Dime 3 cosas pequeñas de mi personalidad que te vuelven loco/a de amor. 🌸',
      'Cuéntame cuál ha sido el sueño más lindo que has tenido conmigo. 🌙',
      'Escríbeme en una servilleta o nota digital un mensaje de amor de 3 líneas. 💌',
      'Dime cuál ha sido el abrazo que más paz te ha transmitido en nuestra historia. 🫂',
    ],
    'fun': [
      'Haz tu mejor imitación de cómo me comporto cuando tengo hambre o sueño. 😂',
      'Baila 30 segundos una canción ridícula elegida por tu pareja. 💃🕺',
      'Cuéntame tu momento más vergonzoso de la infancia que nunca le has dicho a nadie. 🙈',
      'Déjame peinarte o hacerte un peinado gracioso por 5 minutos. 💇‍♂️💇‍♀️',
      'Habla con acento extranjero durante las próximas 3 rondas sin reírte. 🌍',
      'Hazle cosquillas a tu pareja hasta que se ría a carcajadas. 🤭',
      'Tómate una foto graciosa con tu pareja haciendo caras raras ahora mismo. 📸🤪',
    ],
    'spicy': [
      'Dame un beso en el lugar donde nunca me has besado antes. 🔥💋',
      'Susúrrame al oído tu fantasía o deseo más atrevido conmigo. 🌶️',
      'Hazme un masaje relajante de cuello y hombros durante 2 minutos. 💆‍♀️💆‍♂️',
      'Elige una prenda de ropa para que tu pareja se la quite en este momento. 🙈🔥',
      'Dime cuál ha sido el beso que más te ha acelerado el corazón de toda nuestra relación. 💓',
      'Bésame durante 30 segundos sin usar las manos. 💋',
      'Muerde suavemente el lóbulo de mi oreja y susúrrame un piropo atrevido. 👂🔥',
    ],
    'deep': [
      '¿En qué aspecto sientes que nuestra relación te ha hecho una mejor persona? 🌌',
      'Si supieras que nos queda 1 solo año juntos, ¿qué cambiarías hoy mismo? ⏳',
      '¿Qué miedo tenías antes de empezar a salir conmigo que ya superaste? 🛡️',
      '¿Qué es lo que más admiras de mi fortaleza cuando paso por momentos difíciles? 💎',
      '¿Cómo imaginas nuestro hogar y vida juntos dentro de 5 años? 🏡✨',
    ],
  };

  void _drawCard(String category) {
    final list = _truthOrDareCards[category] ?? _truthOrDareCards['romantic']!;
    final random = list[Random().nextInt(list.length)];
    setState(() {
      _currentCardCategory = category;
      _currentCardText = random;
    });

    final couple = Provider.of<CoupleProvider>(context, listen: false);
    couple.addPetXp(5);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 3. RULETA DEL AMOR (LOVE WHEEL) STATE & ANIMATION
  // ─────────────────────────────────────────────────────────────────────────────
  late AnimationController _wheelController;
  late Animation<double> _wheelAnimation;
  double _currentWheelAngle = 0;
  String? _wheelResult;
  bool _isSpinning = false;

  final List<Map<String, dynamic>> _wheelPrizes = [
    {'title': 'Masaje de 10 min 💆', 'color': Color(0xFFFF5E7E), 'icon': '💆'},
    {'title': 'Desayuno en la cama ☕🥞', 'color': Color(0xFFFF8E53), 'icon': '☕'},
    {'title': 'Tú eliges la película 🎬🍿', 'color': Color(0xFF6C5CE7), 'icon': '🎬'},
    {'title': 'Beso apasionado de 1 min 💋', 'color': Color(0xFFFF2A6D), 'icon': '💋'},
    {'title': 'Cocinar tu comida favorita 🍕', 'color': Color(0xFF00B894), 'icon': '🍕'},
    {'title': 'Deseo libre concedido 🧞✨', 'color': Color(0xFFFDCB6E), 'icon': '✨'},
  ];

  @override
  void initState() {
    super.initState();
    _wheelController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _wheelController.dispose();
    super.dispose();
  }

  void _spinWheel() {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
      _wheelResult = null;
    });

    final randomRounds = 4 + Random().nextInt(4);
    final randomSlice = Random().nextInt(_wheelPrizes.length);
    final sliceAngle = (2 * pi) / _wheelPrizes.length;
    final targetAngle = _currentWheelAngle + (randomRounds * 2 * pi) + (randomSlice * sliceAngle);

    _wheelAnimation = Tween<double>(
      begin: _currentWheelAngle,
      end: targetAngle,
    ).animate(CurvedAnimation(parent: _wheelController, curve: Curves.easeOutCubic));

    _wheelController.forward(from: 0).then((_) {
      final normalizedIndex = (_wheelPrizes.length - 1 - (randomSlice % _wheelPrizes.length)) % _wheelPrizes.length;
      setState(() {
        _currentWheelAngle = targetAngle % (2 * pi);
        _wheelResult = _wheelPrizes[normalizedIndex]['title'];
        _isSpinning = false;
      });

      final couple = Provider.of<CoupleProvider>(context, listen: false);
      couple.addPetXp(15);

      _showWheelResultDialog(_wheelPrizes[normalizedIndex]);
    });
  }

  void _showWheelResultDialog(Map<String, dynamic> prize) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Center(child: Text('🎉 ¡Premio del Amor Ganado! 🎉', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(prize['icon'], style: const TextStyle(fontSize: 60)),
            const SizedBox(height: 12),
            Text(
              prize['title'],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.deepWine),
            ),
            const SizedBox(height: 10),
            const Text(
              '¡Tu pareja debe cumplir este premio romántico hoy mismo! (+15 XP para Corazoncito 🐾)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRose,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('¡A Cumplirlo! 💕', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 4. ¿QUÉ PREFIERES? (THIS OR THAT) STATE & DATA
  // ─────────────────────────────────────────────────────────────────────────────
  int _thisOrThatIndex = 0;
  int? _selectedThisOrThatChoice;
  int _thisOrThatCompatibility = 0;

  final List<Map<String, dynamic>> _thisOrThatDilemmas = [
    {
      'title': 'Día de descanso perfecto',
      'optionA': 'Cabaña acogedora en el bosque 🌲🏡',
      'optionB': 'Resort de playa frente al mar 🏖️🍹',
    },
    {
      'title': 'Cena romántica',
      'optionA': 'Cocinar juntos con música y vino 👩‍🍳🍷',
      'optionB': 'Ir a un restaurante nuevo y elegante 🍽️✨',
    },
    {
      'title': 'Noche de fin de semana',
      'optionA': 'Maratón de series en pijamas 📺🍿',
      'optionB': 'Salir de fiesta y bailar juntos 💃🕺',
    },
    {
      'title': 'Planes para vacaciones',
      'optionA': 'Ciudad llena de cultura y museos 🏛️✈️',
      'optionB': 'Naturaleza, senderismo y acampar ⛺🌄',
    },
    {
      'title': 'Forma de consentir a tu amor',
      'optionA': 'Desayuno sorpresa en la cama 🥞☕',
      'optionB': 'Masaje relajante con velitas 💆‍♀️🕯️',
    },
    {
      'title': 'Mascotas en el hogar',
      'optionA': 'Un perrito juguetón y cariñoso 🐶🐾',
      'optionB': 'Un gatito tierno y tranquilo 🐱💕',
    },
    {
      'title': 'Detalles de amor',
      'optionA': 'Cartitas escritas a mano y notas 💌📝',
      'optionB': 'Un ramo de flores o postre sorpresa 💐🍰',
    },
    {
      'title': 'Clima ideal para acurrucarse',
      'optionA': 'Día de lluvia con frío y café 🌧️☕',
      'optionB': 'Tarde cálida y soleada con brisa ☀️🌸',
    },
  ];

  void _chooseThisOrThat(int choice) {
    setState(() {
      _selectedThisOrThatChoice = choice;
      _thisOrThatCompatibility += 12;
    });

    final couple = Provider.of<CoupleProvider>(context, listen: false);
    couple.addPetXp(10);
  }

  void _nextThisOrThat() {
    setState(() {
      _selectedThisOrThatChoice = null;
      _thisOrThatIndex = (_thisOrThatIndex + 1) % _thisOrThatDilemmas.length;
    });
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // BUILD METHOD & UI
  // ─────────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (b) => AppTheme.loveGradient.createShader(b),
          child: const Text(
            'Sala de Minijuegos 🎲',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
              fontFamily: 'Playfair Display',
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.softPink.withOpacity(0.4),
              Colors.white,
              AppTheme.softPink.withOpacity(0.2),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Scrollable Game Selector Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  _buildTabButton(0, '🎯 Quiz de Pareja', theme),
                  const SizedBox(width: 8),
                  _buildTabButton(1, '🃏 Cartas & Retos', theme),
                  const SizedBox(width: 8),
                  _buildTabButton(2, '🎡 Ruleta del Amor', theme),
                  const SizedBox(width: 8),
                  _buildTabButton(3, '💕 ¿Qué Prefieres?', theme),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Active Game View
            Expanded(
              child: _buildActiveGame(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String title, ThemeProvider theme) {
    final isSelected = _activeGameIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _activeGameIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.loveGradient : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFFFFE0E8),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryRose.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.deepWine,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveGame(ThemeProvider theme) {
    switch (_activeGameIndex) {
      case 0:
        return _buildQuizGame(theme);
      case 1:
        return _buildTruthOrDareGame(theme);
      case 2:
        return _buildLoveWheelGame(theme);
      case 3:
        return _buildThisOrThatGame(theme);
      default:
        return _buildQuizGame(theme);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 1. QUIZ UI
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildQuizGame(ThemeProvider theme) {
    if (_quizFinished) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFFFE0E8), width: 1.5),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🏆', style: TextStyle(fontSize: 50)),
                const SizedBox(height: 10),
                const Text(
                  '¡Test de Conexión Completado!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.deepWine),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Conexión: 100% 💕',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.primaryRose),
                ),
                const Text(
                  'Tus respuestas sinceras (+30 XP para Corazoncito 🐾)',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ...List.generate(_currentQuizQuestions.length, (i) {
                  final q = _currentQuizQuestions[i];
                  final ans = i < _userAnswers.length ? _userAnswers[i] : '';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9FA),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFFE0E8)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${i + 1}. ${q['question']}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF880E4F)),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text('Respuesta: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
                            Expanded(
                              child: Text(
                                ans,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2B2B2B)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryRose,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => _restartQuiz(_quizCategory),
                    icon: const Icon(Icons.replay_rounded, color: Colors.white),
                    label: const Text('Jugar de Nuevo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final questions = _currentQuizQuestions;
    final currentQ = questions[_quizStep];

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Selector Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuizCategoryChip('romance', '💕 Romance'),
                const SizedBox(width: 8),
                _buildQuizCategoryChip('food_habits', '🍕 Gustos & Hábitos'),
                const SizedBox(width: 8),
                _buildQuizCategoryChip('spicy', '🔥 Intimidad'),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Progress Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pregunta ${_quizStep + 1} de ${questions.length}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryRose),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFE8F8F1), borderRadius: BorderRadius.circular(12)),
                child: const Text('+30 XP 🐾', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00C9A7), fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (_quizStep + 1) / questions.length,
              backgroundColor: const Color(0xFFFFE0E8),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryRose),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 18),

          // Question Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFFE0E8), width: 1.2),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Text(
              currentQ['question'],
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppTheme.deepWine,
                height: 1.35,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Options List
          Expanded(
            child: ListView.builder(
              itemCount: currentQ['options'].length,
              itemBuilder: (context, index) {
                final opt = currentQ['options'][index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: InkWell(
                    onTap: () => _answerQuiz(index),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFFFE0E8)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppTheme.softPink,
                            child: Text(
                              String.fromCharCode(65 + index),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryRose),
                            ),
                          ),
                          const SizedBox(width: 12),
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
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCategoryChip(String category, String label) {
    final isSelected = _quizCategory == category;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.softPink,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryRose : Colors.grey,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      onSelected: (_) => _restartQuiz(category),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 2. VERDAD O RETO UI
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildTruthOrDareGame(ThemeProvider theme) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Category Selector Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCardCategoryChip('romantic', '💕 Romántico', Colors.pink),
                const SizedBox(width: 8),
                _buildCardCategoryChip('fun', '😂 Divertido', Colors.orange),
                const SizedBox(width: 8),
                _buildCardCategoryChip('spicy', '🔥 Atrevido', Colors.redAccent),
                const SizedBox(width: 8),
                _buildCardCategoryChip('deep', '🌌 Profundo', Colors.purple),
              ],
            ),
          ),

          const Spacer(),

          // Card Deck Animation
          Container(
            height: 250,
            width: double.infinity,
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              gradient: AppTheme.loveGradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryRose.withOpacity(0.35),
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
                  height: 1.45,
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
                backgroundColor: AppTheme.primaryRose,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 4,
              ),
              onPressed: () => _drawCard(_currentCardCategory),
              icon: const Icon(Icons.style_rounded, color: Colors.white),
              label: const Text('¡Sacar Otra Carta! 🃏 (+5 XP)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildCardCategoryChip(String category, String label, Color color) {
    final isSelected = _currentCardCategory == category;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: color.withOpacity(0.18),
      labelStyle: TextStyle(
        color: isSelected ? color : Colors.grey,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      onSelected: (_) => _drawCard(category),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 3. RULETA DEL AMOR UI
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildLoveWheelGame(ThemeProvider theme) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const Text(
            '¡Gira la Ruleta y Gana un Premio Romántico! 🎡',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.deepWine),
          ),
          const SizedBox(height: 6),
          const Text(
            'Lo que salga, tu pareja tendrá que cumplirlo hoy 💕',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
          const Spacer(),

          // Wheel Stack
          Stack(
            alignment: Alignment.center,
            children: [
              // Pointer
              Positioned(
                top: 0,
                child: Container(
                  width: 24,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppTheme.deepWine,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 24),
                ),
              ),

              // Animated Rotating Wheel
              AnimatedBuilder(
                animation: _wheelController,
                builder: (context, child) {
                  final angle = _wheelController.isAnimating ? _wheelAnimation.value : _currentWheelAngle;
                  return Transform.rotate(
                    angle: angle,
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryRose.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: CustomPaint(
                        painter: _LoveWheelPainter(prizes: _wheelPrizes),
                      ),
                    ),
                  );
                },
              ),

              // Center Hub
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppTheme.loveGradient,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8),
                  ],
                ),
                child: const Center(
                  child: Text('💖', style: TextStyle(fontSize: 24)),
                ),
              ),
            ],
          ),

          const Spacer(),

          // Spin Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRose,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 4,
              ),
              onPressed: _isSpinning ? null : _spinWheel,
              icon: const Icon(Icons.rotate_right_rounded, color: Colors.white),
              label: Text(
                _isSpinning ? '¡Girando la Ruleta... ✨' : '¡Girar Ruleta! 🎡 (+15 XP)',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 4. ¿QUÉ PREFIERES? (THIS OR THAT) UI
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildThisOrThatGame(ThemeProvider theme) {
    final dilemma = _thisOrThatDilemmas[_thisOrThatIndex];

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dilema ${_thisOrThatIndex + 1} de ${_thisOrThatDilemmas.length}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryRose),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFE8F8F1), borderRadius: BorderRadius.circular(12)),
                child: Text('Compatibilidad: $_thisOrThatCompatibility% ✨', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00C9A7), fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            dilemma['title'],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.deepWine),
          ),
          const SizedBox(height: 6),
          const Text(
            'Elige tu opción favorita y mira si coinciden 💕',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 20),

          // Option A Card
          _buildThisOrThatCard(
            text: dilemma['optionA'],
            index: 0,
            color: const Color(0xFFFF5E7E),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Center(
              child: Text(
                '⚡ O PREFIERES ⚡',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppTheme.primaryRose, letterSpacing: 1.5),
              ),
            ),
          ),

          // Option B Card
          _buildThisOrThatCard(
            text: dilemma['optionB'],
            index: 1,
            color: const Color(0xFF6C5CE7),
          ),

          const Spacer(),

          if (_selectedThisOrThatChoice != null)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRose,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _nextThisOrThat,
                icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                label: const Text('Siguiente Dilema ➡️', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildThisOrThatCard({required String text, required int index, required Color color}) {
    final isSelected = _selectedThisOrThatChoice == index;

    return InkWell(
      onTap: _selectedThisOrThatChoice == null ? () => _chooseThisOrThat(index) : null,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFFFE0E8),
            width: isSelected ? 2.5 : 1.2,
          ),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? color : AppTheme.softPink,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  isSelected ? Icons.check : (index == 0 ? Icons.favorite_rounded : Icons.star_rounded),
                  color: isSelected ? Colors.white : color,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : const Color(0xFF2B2B2B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOM PAINTER FOR LOVE WHEEL
// ─────────────────────────────────────────────────────────────────────────────
class _LoveWheelPainter extends CustomPainter {
  final List<Map<String, dynamic>> prizes;

  _LoveWheelPainter({required this.prizes});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sweepAngle = (2 * pi) / prizes.length;

    for (int i = 0; i < prizes.length; i++) {
      final paint = Paint()
        ..color = prizes[i]['color'] as Color
        ..style = PaintingStyle.fill;

      final startAngle = i * sweepAngle;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Border lines between slices
      final linePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2.5;
      final x = center.dx + radius * cos(startAngle);
      final y = center.dy + radius * sin(startAngle);
      canvas.drawLine(center, Offset(x, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
