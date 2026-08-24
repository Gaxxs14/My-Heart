import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';

class CoupleProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final SocketService _socketService = SocketService();

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _coupleData;
  String? _pairingCode;
  bool _isPaired = false;

  // Real-time Love Timer
  Timer? _tickerTimer;
  int _daysTogether = 0;
  int _hoursTogether = 0;
  int _minutesTogether = 0;
  int _secondsTogether = 0;

  // Heartbeat trigger for UI animation
  bool _showHeartbeatAnimation = false;
  String? _lastHeartbeatSender;

  // Daily Sparks
  Map<String, dynamic>? _todayQuestion;
  bool _isLoadingQuestion = false;

  // Memories & Timeline
  List<dynamic> _memories = [];
  bool _isLoadingMemories = false;

  // Bucket List
  List<dynamic> _bucketList = [];
  bool _isLoadingBucket = false;

  // Secret Letters
  List<dynamic> _letters = [];
  bool _isLoadingLetters = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get coupleData => _coupleData;
  String? get pairingCode => _pairingCode;
  bool get isPaired => _isPaired;

  int get daysTogether => _daysTogether;
  int get hoursTogether => _hoursTogether;
  int get minutesTogether => _minutesTogether;
  int get secondsTogether => _secondsTogether;

  bool get showHeartbeatAnimation => _showHeartbeatAnimation;
  String? get lastHeartbeatSender => _lastHeartbeatSender;

  Map<String, dynamic>? get todayQuestion => _todayQuestion;
  bool get isLoadingQuestion => _isLoadingQuestion;

  List<dynamic> get memories => _memories;
  bool get isLoadingMemories => _isLoadingMemories;

  List<dynamic> get bucketList => _bucketList;
  bool get isLoadingBucket => _isLoadingBucket;

  List<dynamic> get letters => _letters;
  bool get isLoadingLetters => _isLoadingLetters;

  int get petLevel => _coupleData?['pet_level'] ?? 1;
  int get petXp => _coupleData?['pet_xp'] ?? 0;
  String get petName => _coupleData?['pet_name'] ?? 'Corazoncito';

  void loadDemoData() {
    _isPaired = true;
    _coupleData = {
      'id': 'demo-couple-1',
      'pairing_code': 'DEMO-HEART',
      'pet_name': 'Corazoncito',
      'pet_level': 3,
      'pet_xp': 65,
      'anniversary_date': DateTime.now().subtract(const Duration(days: 420)).toIso8601String().split('T').first,
      'relationship_time_start': DateTime.now().subtract(const Duration(days: 420)).toIso8601String(),
    };
    _startLoveTicker();

    _todayQuestion = {
      'question': {
        'id': 'demo-q-1',
        'emoji': '✨',
        'category': 'deep',
        'question_text': '¿Cuál fue el momento exacto en que te diste cuenta de que te gustaba?',
      },
      'user_answered': true,
      'user_answer': 'El día que fuimos por café y nos quedamos hablando por horas bajo la lluvia ☕🌧️',
      'partner_answered': true,
      'partner_answer': 'Cuando me hiciste reír tanto que se me cayó el helado y no te importó ensuciarte para ayudarme 🍦❤️',
      'is_locked_for_user': false,
      'both_answered': true,
    };

    _memories = [
      {
        'id': 'demo-m-1',
        'title': 'Nuestra primera cita 🍷',
        'description': 'Cenamos pasta y nos quedamos platicando hasta que cerraron el restaurante.',
        'memory_date': '2024-02-14',
        'location_name': 'Trattoria Bella',
        'author_name': 'Mi Amor',
      },
      {
        'id': 'demo-m-2',
        'title': 'Paseo al atardecer en el mirador 🌅',
        'description': 'Llevamos café caliente y vimos cómo se encendían las luces de la ciudad.',
        'memory_date': '2024-08-20',
        'location_name': 'Mirador del Valle',
        'author_name': 'Gabriel',
      },
    ];

    _bucketList = [
      {
        'id': 'demo-b-1',
        'title': 'Ver las auroras boreales juntos 🌌',
        'description': 'Viaje soñado a Islandia o Noruega.',
        'is_completed': false,
        'category': 'travel',
      },
      {
        'id': 'demo-b-2',
        'title': 'Noche de cine bajo las estrellas 🎬🍿',
        'description': 'Con proyector y muchas mantitas.',
        'is_completed': true,
        'completed_date': '2024-07-15',
        'category': 'date_night',
      },
      {
        'id': 'demo-b-3',
        'title': 'Cocinar pizza artesanal desde cero 🍕',
        'description': 'Quedó deliciosa.',
        'is_completed': true,
        'completed_date': '2024-05-10',
        'category': 'home',
      },
    ];

    _letters = [
      {
        'id': 'demo-l-1',
        'sender_name': 'Mi Amor',
        'title': 'Para cuando tengas un día difícil 💌',
        'content': 'Solo quiero recordarte lo increíble que eres y cuánto te amo. No importa lo difícil que sea el día, siempre estaré aquí para ti con un abrazo.',
        'is_unlocked': true,
        'is_opened': true,
      },
      {
        'id': 'demo-l-2',
        'sender_name': 'Mi Amor',
        'title': 'Nuestro próximo aniversario 🎂',
        'unlock_type': 'date',
        'unlock_date': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        'is_unlocked': false,
        'is_opened': false,
      },
    ];

    notifyListeners();
  }

  // Initialize couple state and real-time sockets
  Future<void> initCouple({
    required String userId,
    required String? coupleId,
    required Function(String mood, String icon) onPartnerMood,
    required Function(bool online) onPartnerOnline,
  }) async {
    if (coupleId == 'demo-couple-1') {
      loadDemoData();
      return;
    }
    await fetchCoupleStatus();

    if (_isPaired && _coupleData != null) {
      _startLoveTicker();

      // Connect WebSockets
      _socketService.connect(
        userId: userId,
        coupleId: _coupleData!['id'],
        onHeartbeatReceived: (data) {
          triggerHeartbeatReceived(data['senderName'] ?? 'Tu pareja');
        },
        onPartnerMoodUpdated: (data) {
          onPartnerMood(data['moodStatus'] ?? '', data['moodIcon'] ?? '🥰');
        },
        onPartnerPresence: (data) {
          onPartnerOnline(data['is_online'] ?? false);
        },
      );

      // Load initial feature data
      loadTodayQuestion();
      loadMemories();
      loadBucketList();
      loadLetters();
    }
  }

  Future<void> fetchCoupleStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _apiService.get('/couple/status');
      _isPaired = res['is_paired'] ?? false;
      if (_isPaired) {
        _coupleData = res['couple'];
        _calculateLoveDuration();
      } else {
        _pairingCode = res['pairing_code'];
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> generateNewCode() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.post('/couple/create-code', {});
      _pairingCode = res['pairing_code'];
      _isLoading = false;
      notifyListeners();
      return _pairingCode;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> linkWithCode(String code, {DateTime? anniversaryDate}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.post('/couple/link-code', {
        'code': code,
        'anniversary_date': anniversaryDate?.toIso8601String().split('T').first,
      });

      _coupleData = res['couple'];
      _isPaired = true;
      _startLoveTicker();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Real-time Love Ticker
  void _startLoveTicker() {
    _tickerTimer?.cancel();
    _calculateLoveDuration();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _calculateLoveDuration();
    });
  }

  void _calculateLoveDuration() {
    if (_coupleData == null) return;
    final startDateStr = _coupleData!['anniversary_date'] ?? _coupleData!['relationship_time_start'] ?? _coupleData!['created_at'];
    if (startDateStr == null) return;

    final startDate = DateTime.tryParse(startDateStr.toString()) ?? DateTime.now();
    final difference = DateTime.now().difference(startDate);

    if (difference.isNegative) {
      _daysTogether = 0;
      _hoursTogether = 0;
      _minutesTogether = 0;
      _secondsTogether = 0;
    } else {
      _daysTogether = difference.inDays;
      _hoursTogether = difference.inHours % 24;
      _minutesTogether = difference.inMinutes % 60;
      _secondsTogether = difference.inSeconds % 60;
    }
    notifyListeners();
  }

  // Trigger Heartbeat to Partner
  void sendHeartbeat({required String userId, required String userName}) {
    if (!_isPaired || _coupleData == null) return;

    HapticFeedback.heavyImpact();

    // Trigger local feedback animation
    _showHeartbeatAnimation = true;
    _lastHeartbeatSender = 'Tú';
    notifyListeners();

    Timer(const Duration(seconds: 3), () {
      _showHeartbeatAnimation = false;
      notifyListeners();
    });

    if (_coupleData?['id'] != 'demo-couple-1') {
      _socketService.sendHeartbeat(
        coupleId: _coupleData!['id'],
        senderId: userId,
        senderName: userName,
      );
    }
  }

  void triggerHeartbeatReceived(String senderName) {
    HapticFeedback.vibrate();
    _showHeartbeatAnimation = true;
    _lastHeartbeatSender = senderName;
    notifyListeners();

    Timer(const Duration(seconds: 4), () {
      _showHeartbeatAnimation = false;
      notifyListeners();
    });
  }

  // Daily Sparks
  Future<void> loadTodayQuestion() async {
    if (_coupleData?['id'] == 'demo-couple-1') return;

    _isLoadingQuestion = true;
    notifyListeners();

    try {
      final res = await _apiService.get('/questions/today');
      _todayQuestion = res;
    } catch (e) {
      print('Error cargando pregunta: $e');
    }

    _isLoadingQuestion = false;
    notifyListeners();
  }

  Future<bool> answerTodayQuestion(String questionId, String answerText) async {
    if (_coupleData?['id'] == 'demo-couple-1') {
      _todayQuestion = {
        'question': _todayQuestion?['question'] ?? {
          'id': 'demo-q-1',
          'emoji': '✨',
          'category': 'deep',
          'question_text': '¿Cuál fue el momento exacto en que te diste cuenta de que te gustaba?',
        },
        'user_answered': true,
        'user_answer': answerText,
        'partner_answered': true,
        'partner_answer': 'Cuando me hiciste reír tanto que se me cayó el helado y no te importó ensuciarte para ayudarme 🍦❤️',
        'is_locked_for_user': false,
        'both_answered': true,
      };
      _coupleData!['pet_xp'] = (_coupleData!['pet_xp'] as int) + 15;
      notifyListeners();
      return true;
    }

    try {
      await _apiService.post('/questions/answer', {
        'question_id': questionId,
        'answer_text': answerText,
      });

      // Reload today question to unlock answers
      await loadTodayQuestion();
      await fetchCoupleStatus(); // Updates XP
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // Memories
  Future<void> loadMemories() async {
    if (_coupleData?['id'] == 'demo-couple-1') return;

    _isLoadingMemories = true;
    notifyListeners();

    try {
      final res = await _apiService.get('/memories');
      _memories = res['memories'] ?? [];
    } catch (e) {
      print('Error cargando recuerdos: $e');
    }

    _isLoadingMemories = false;
    notifyListeners();
  }

  Future<bool> addMemory({
    required String title,
    String? description,
    required String memoryDate,
    String? locationName,
  }) async {
    if (_coupleData?['id'] == 'demo-couple-1') {
      _memories.insert(0, {
        'id': 'demo-m-${DateTime.now().millisecondsSinceEpoch}',
        'title': title,
        'description': description ?? '',
        'memory_date': memoryDate,
        'location_name': locationName,
        'author_name': 'Tú',
      });
      _coupleData!['pet_xp'] = (_coupleData!['pet_xp'] as int) + 20;
      notifyListeners();
      return true;
    }

    try {
      await _apiService.post('/memories', {
        'title': title,
        'description': description,
        'memory_date': memoryDate,
        'location_name': locationName,
      });
      await loadMemories();
      await fetchCoupleStatus();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // Bucket List
  Future<void> loadBucketList() async {
    if (_coupleData?['id'] == 'demo-couple-1') return;

    _isLoadingBucket = true;
    notifyListeners();

    try {
      final res = await _apiService.get('/bucket');
      _bucketList = res['items'] ?? [];
    } catch (e) {
      print('Error cargando bucket list: $e');
    }

    _isLoadingBucket = false;
    notifyListeners();
  }

  Future<bool> addBucketItem(String title, {String? category, String? description}) async {
    if (_coupleData?['id'] == 'demo-couple-1') {
      _bucketList.insert(0, {
        'id': 'demo-b-${DateTime.now().millisecondsSinceEpoch}',
        'title': title,
        'category': category ?? 'date_night',
        'description': description ?? '',
        'is_completed': false,
      });
      notifyListeners();
      return true;
    }

    try {
      await _apiService.post('/bucket', {
        'title': title,
        'category': category ?? 'date_night',
        'description': description ?? '',
      });
      await loadBucketList();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleBucketItem(String itemId, bool isCompleted) async {
    if (_coupleData?['id'] == 'demo-couple-1') {
      final index = _bucketList.indexWhere((item) => item['id'] == itemId);
      if (index != -1) {
        _bucketList[index]['is_completed'] = isCompleted;
        if (isCompleted) {
          _coupleData!['pet_xp'] = (_coupleData!['pet_xp'] as int) + 50;
        }
        notifyListeners();
      }
      return;
    }

    try {
      await _apiService.patch('/bucket/$itemId', {
        'is_completed': isCompleted,
      });
      await loadBucketList();
      await fetchCoupleStatus();
    } catch (e) {
      print('Error alternando bucket item: $e');
    }
  }

  // Secret Letters
  Future<void> loadLetters() async {
    if (_coupleData?['id'] == 'demo-couple-1') return;

    _isLoadingLetters = true;
    notifyListeners();

    try {
      final res = await _apiService.get('/letters');
      _letters = res['letters'] ?? [];
    } catch (e) {
      print('Error cargando cartas: $e');
    }

    _isLoadingLetters = false;
    notifyListeners();
  }

  Future<bool> sendSecretLetter({
    required String title,
    required String content,
    String unlockType = 'date',
    DateTime? unlockDate,
    String? unlockMood,
  }) async {
    if (_coupleData?['id'] == 'demo-couple-1') {
      _letters.insert(0, {
        'id': 'demo-l-${DateTime.now().millisecondsSinceEpoch}',
        'sender_name': 'Tú',
        'title': title,
        'content': content,
        'unlock_type': unlockType,
        'unlock_date': unlockDate?.toIso8601String(),
        'is_unlocked': unlockDate == null || unlockDate.isBefore(DateTime.now()),
        'is_opened': false,
      });
      notifyListeners();
      return true;
    }

    try {
      await _apiService.post('/letters', {
        'title': title,
        'content': content,
        'unlock_type': unlockType,
        'unlock_date': unlockDate?.toIso8601String(),
        'unlock_mood': unlockMood,
      });
      await loadLetters();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    _socketService.disconnect();
    super.dispose();
  }
}
