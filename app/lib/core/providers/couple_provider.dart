import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../services/notification_service.dart';

class CoupleProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final SocketService _socketService = SocketService();
  final NotificationService _notificationService = NotificationService();

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
  List<dynamic> _questionHistory = [];
  List<dynamic> get questionHistory => _questionHistory;

  // Memories & Timeline
  List<dynamic> _memories = [];
  bool _isLoadingMemories = false;

  // Bucket List
  List<dynamic> _bucketList = [];
  bool _isLoadingBucket = false;

  // Secret Letters
  List<dynamic> _letters = [];
  bool _isLoadingLetters = false;

  // Our Song (Music Player)
  String _loveSongTitle = 'Perfect';
  String _loveSongArtist = 'Ed Sheeran';
  String? _loveSongUrl;
  bool _isSongPlaying = false;
  AudioPlayer? _audioPlayer;

  // Pet
  String _petName = 'Corazoncito';
  String _petType = 'puppy';
  int _petLevel = 1;
  int _petXp = 0;

  // Romantic Places
  List<dynamic> _places = [];

  // Sticky Notes (Post-its)
  List<dynamic> _stickyNotes = [];

  // Calendar Events
  List<dynamic> _events = [];

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

  String get loveSongTitle => _coupleData?['love_song_title'] ?? _loveSongTitle;
  String get loveSongArtist => _coupleData?['love_song_artist'] ?? _loveSongArtist;
  String? get loveSongUrl => _coupleData?['love_song_url'] ?? _loveSongUrl;
  bool get isSongPlaying => _isSongPlaying;

  List<dynamic> get places => _places;
  List<dynamic> get stickyNotes => _stickyNotes;
  List<dynamic> get events => _events;

  String get petType => _coupleData?['pet_type'] ?? _petType;
  String get petName => _coupleData?['pet_name'] ?? _petName;
  int get petLevel => _coupleData?['pet_level'] ?? _petLevel;
  int get petXp => _coupleData?['pet_xp'] ?? _petXp;

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
      'user_answered': false,
      'user_answer': null,
      'partner_answered': true,
      'partner_answer': 'Cuando me hiciste reír tanto que se me cayó el helado y no te importó ensuciarte para ayudarme 🍦❤️',
      'is_locked_for_user': true,
      'both_answered': false,
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

    _places = [
      {
        'id': 'demo-p-1',
        'name': 'Trattoria Bella 🍝',
        'city': 'Centro Histórico',
        'category': 'restaurant',
        'date': '2024-02-14',
        'note': 'Nuestra primera cena romántica oficial.',
      },
      {
        'id': 'demo-p-2',
        'name': 'Mirador de las Luces 🌅',
        'city': 'Zona Alta',
        'category': 'viewpoint',
        'date': '2024-08-20',
        'note': 'El mejor atardecer que hemos visto juntos.',
      },
      {
        'id': 'demo-p-3',
        'name': 'Café Aromas & Libros ☕📚',
        'city': 'Barrio Antiguo',
        'category': 'cafe',
        'date': '2024-11-05',
        'note': 'Donde nos quedamos platicando 4 horas.',
      },
    ];

    _stickyNotes = [
      {
        'id': 'demo-n-1',
        'author_name': 'Mi Amor',
        'content': '¡Buenos días mi vida! Te amo infinito 💕 Recuerda tomar café.',
        'color': 'pink',
        'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      },
      {
        'id': 'demo-n-2',
        'author_name': 'Gabriel',
        'content': '¿Cenamos pizza casera hoy en la noche? 🍕✨',
        'color': 'yellow',
        'created_at': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
      },
    ];

    _events = [
      {
        'id': 'demo-e-1',
        'title': 'Nuestro Aniversario 💖',
        'date': DateTime.now().add(const Duration(days: 14)).toIso8601String().split('T').first,
        'emoji': '🎂',
        'type': 'anniversary',
      },
      {
        'id': 'demo-e-2',
        'title': 'Cena Romántica de Viernes 🍷',
        'date': DateTime.now().add(const Duration(days: 4)).toIso8601String().split('T').first,
        'emoji': '🍷',
        'type': 'date',
      },
      {
        'id': 'demo-e-3',
        'title': 'Viaje a la Montaña 🌲⛺',
        'date': DateTime.now().add(const Duration(days: 28)).toIso8601String().split('T').first,
        'emoji': '⛺',
        'type': 'trip',
      },
    ];

    notifyListeners();
  }

  // Pet Management Methods
  Future<void> updatePet({required String type, required String name}) async {
    _petType = type;
    _petName = name;
    if (_coupleData != null) {
      _coupleData!['pet_type'] = type;
      _coupleData!['pet_name'] = name;
    }
    notifyListeners();

    try {
      await _apiService.patch('/couple/settings', {
        'pet_type': type,
        'pet_name': name,
      });
      if (_coupleData?['id'] != null && _coupleData?['id'] != 'demo-couple-1') {
        _socketService.emitDataChanged(coupleId: _coupleData!['id'], type: 'pet');
      }
    } catch (_) {}
  }

  Future<void> addPetXp(int xp) async {
    _petXp += xp;
    _petLevel = (_petXp ~/ 100) + 1;
    if (_coupleData != null) {
      _coupleData!['pet_xp'] = _petXp;
      _coupleData!['pet_level'] = _petLevel;
    }
    notifyListeners();

    try {
      await _apiService.patch('/couple/settings', {
        'pet_xp': _petXp,
        'pet_level': _petLevel,
      });
      if (_coupleData?['id'] != null && _coupleData?['id'] != 'demo-couple-1') {
        _socketService.emitDataChanged(coupleId: _coupleData!['id'], type: 'pet');
      }
    } catch (_) {}
  }

  // Music Player Methods
  Future<void> updateLoveSong(String title, String artist, {String? url}) async {
    _loveSongTitle = title;
    _loveSongArtist = artist;
    if (url != null) _loveSongUrl = url;
    if (_coupleData != null) {
      _coupleData!['love_song_title'] = title;
      _coupleData!['love_song_artist'] = artist;
      if (url != null) _coupleData!['love_song_url'] = url;
    }
    notifyListeners();

    try {
      await _apiService.patch('/couple/settings', {
        'love_song_title': title,
        'love_song_artist': artist,
        'love_song_url': url ?? _loveSongUrl,
      });
      if (_coupleData?['id'] != null && _coupleData?['id'] != 'demo-couple-1') {
        _socketService.emitDataChanged(coupleId: _coupleData!['id'], type: 'song');
      }
    } catch (_) {}
  }

  Future<void> togglePlaySong() async {
    _audioPlayer ??= AudioPlayer();

    if (_isSongPlaying) {
      await _audioPlayer?.pause();
      _isSongPlaying = false;
      notifyListeners();
    } else {
      _isSongPlaying = true;
      notifyListeners();
      try {
        final url = loveSongUrl;
        if (url != null && url.isNotEmpty) {
          if (url.startsWith('http://') || url.startsWith('https://')) {
            await _audioPlayer?.play(UrlSource(url));
          } else {
            await _audioPlayer?.play(DeviceFileSource(url));
          }
        } else {
          // Romantic piano melody stream fallback
          await _audioPlayer?.play(UrlSource('https://cdn.pixabay.com/download/audio/2022/05/27/audio_1808fbf07a.mp3?filename=romantic-piano-112199.mp3'));
        }

        _audioPlayer?.onPlayerComplete.listen((_) {
          _isSongPlaying = false;
          notifyListeners();
        });
      } catch (e) {
        _isSongPlaying = false;
        notifyListeners();
      }
    }
  }

  // Places Methods
  Future<void> loadPlaces() async {
    if (_coupleData?['id'] == 'demo-couple-1') return;
    try {
      final res = await _apiService.get('/places');
      _places = res['places'] ?? [];
      notifyListeners();
    } catch (e) {
      print('Error cargando lugares: $e');
    }
  }

  Future<bool> addPlace({
    required String name,
    required String city,
    required String category,
    String? note,
    String? visitDate,
  }) async {
    if (_coupleData?['id'] == 'demo-couple-1') {
      _places.insert(0, {
        'id': 'demo-p-${DateTime.now().millisecondsSinceEpoch}',
        'name': name,
        'city': city,
        'category': category,
        'date': visitDate ?? DateTime.now().toIso8601String().split('T').first,
        'note': note ?? '',
      });
      if (_coupleData != null) {
        _coupleData!['pet_xp'] = (_coupleData!['pet_xp'] as int) + 25;
      }
      notifyListeners();
      return true;
    }

    try {
      await _apiService.post('/places', {
        'name': name,
        'city': city,
        'category': category,
        'note': note,
        'visit_date': visitDate,
      });
      await loadPlaces();
      await fetchCoupleStatus();
      if (_coupleData?['id'] != null) {
        _socketService.emitDataChanged(
          coupleId: _coupleData!['id'],
          type: 'places',
        );
      }
      return true;
    } catch (e) {
      print('Error creando lugar romántico: $e');
      return false;
    }
  }

  // Sticky Notes Methods
  Future<void> loadStickyNotes() async {
    if (_coupleData?['id'] == 'demo-couple-1') return;
    try {
      final res = await _apiService.get('/sticky-notes');
      _stickyNotes = res['notes'] ?? [];
      notifyListeners();
    } catch (e) {
      print('Error cargando notas: $e');
    }
  }

  Future<bool> addStickyNote({
    required String content,
    required String color,
    required String authorName,
  }) async {
    if (_coupleData?['id'] == 'demo-couple-1') {
      _stickyNotes.insert(0, {
        'id': 'demo-n-${DateTime.now().millisecondsSinceEpoch}',
        'author_name': authorName,
        'content': content,
        'color': color,
        'created_at': DateTime.now().toIso8601String(),
      });
      if (_coupleData != null) {
        _coupleData!['pet_xp'] = (_coupleData!['pet_xp'] as int) + 10;
      }
      notifyListeners();
      return true;
    }

    try {
      await _apiService.post('/sticky-notes', {
        'content': content,
        'color': color,
      });
      await loadStickyNotes();
      await fetchCoupleStatus();
      if (_coupleData?['id'] != null) {
        _socketService.emitDataChanged(
          coupleId: _coupleData!['id'],
          type: 'notes',
        );
      }
      return true;
    } catch (e) {
      print('Error creando nota: $e');
      return false;
    }
  }

  Future<void> deleteStickyNote(String id) async {
    _stickyNotes.removeWhere((n) => n['id'] == id);
    notifyListeners();

    if (_coupleData?['id'] == 'demo-couple-1') return;

    try {
      await _apiService.delete('/sticky-notes/$id');
      if (_coupleData?['id'] != null) {
        _socketService.emitDataChanged(
          coupleId: _coupleData!['id'],
          type: 'notes',
        );
      }
    } catch (e) {
      print('Error eliminando nota: $e');
    }
  }

  // Calendar Events Methods
  Future<void> loadCalendarEvents() async {
    if (_coupleData?['id'] == 'demo-couple-1') return;
    try {
      final res = await _apiService.get('/calendar');
      final rawEvents = res['events'] as List? ?? [];
      _events = rawEvents.map((e) {
        final map = Map<String, dynamic>.from(e);
        map['date'] = map['event_date'] ?? map['date'];
        return map;
      }).toList();
      notifyListeners();
    } catch (e) {
      print('Error cargando calendario: $e');
    }
  }

  Future<bool> addCalendarEvent({
    required String title,
    required String date,
    required String emoji,
    required String type,
  }) async {
    if (_coupleData?['id'] == 'demo-couple-1') {
      _events.add({
        'id': 'demo-e-${DateTime.now().millisecondsSinceEpoch}',
        'title': title,
        'date': date,
        'emoji': emoji,
        'type': type,
      });
      _events.sort((a, b) => a['date'].toString().compareTo(b['date'].toString()));
      notifyListeners();
      return true;
    }

    try {
      await _apiService.post('/calendar', {
        'title': title,
        'event_date': date,
        'emoji': emoji,
        'event_type': type,
      });
      await loadCalendarEvents();
      if (_coupleData?['id'] != null) {
        _socketService.emitDataChanged(
          coupleId: _coupleData!['id'],
          type: 'calendar',
        );
      }
      return true;
    } catch (e) {
      print('Error creando evento de calendario: $e');
      return false;
    }
  }

  Future<void> deleteCalendarEvent(String id) async {
    _events.removeWhere((e) => e['id'] == id);
    notifyListeners();

    if (_coupleData?['id'] == 'demo-couple-1') return;

    try {
      await _apiService.delete('/calendar/$id');
      if (_coupleData?['id'] != null) {
        _socketService.emitDataChanged(
          coupleId: _coupleData!['id'],
          type: 'calendar',
        );
      }
    } catch (e) {
      print('Error eliminando evento: $e');
    }
  }

  // Real-time synchronization dispatcher
  void _handlePartnerRefresh(String? type) {
    switch (type) {
      case 'notes':
        loadStickyNotes();
        _notificationService.showNotification(
          title: '📝 Nueva Notita de Amor',
          body: 'Tu pareja te dejó una notita en el muro de amor.',
        );
        break;
      case 'calendar':
        loadCalendarEvents();
        _notificationService.showNotification(
          title: '📅 Nueva Fecha Especial',
          body: 'Tu pareja añadió un evento al calendario.',
        );
        break;
      case 'places':
        loadPlaces();
        _notificationService.showNotification(
          title: '📍 Nuevo Lugar Romántico',
          body: 'Tu pareja añadió un nuevo lugar a su mapa de recuerdos.',
        );
        break;
      case 'memories':
        loadMemories();
        fetchCoupleStatus();
        _notificationService.showNotification(
          title: '📸 Nuevo Recuerdo Compartido',
          body: 'Tu pareja agregó un momento especial a su historia.',
        );
        break;
      case 'bucket':
        loadBucketList();
        fetchCoupleStatus();
        _notificationService.showNotification(
          title: '🌟 Bucket List Actualizado',
          body: 'Se actualizó una meta de su lista de deseos.',
        );
        break;
      case 'letters':
        loadLetters();
        _notificationService.showNotification(
          title: '💌 Nueva Carta Secreta',
          body: 'Tu pareja selló una carta en la cápsula del tiempo.',
        );
        break;
      case 'question':
        loadTodayQuestion();
        fetchCoupleStatus();
        _notificationService.showNotification(
          title: '💬 Pregunta del Día Respondida',
          body: '¡Tu pareja respondió la pregunta de hoy! Entra a ver su respuesta.',
        );
        break;
      case 'pet':
        fetchCoupleStatus();
        _notificationService.showNotification(
          title: '🐾 Tu Mascota está Feliz',
          body: 'Tu pareja cuidó a su mascota virtual.',
        );
        break;
      case 'song':
        fetchCoupleStatus();
        _notificationService.showNotification(
          title: '🎵 Canción de Amor Actualizada',
          body: 'Tu pareja actualizó la canción de su historia.',
        );
        break;
      case 'all':
      default:
        fetchCoupleStatus();
        loadTodayQuestion();
        loadMemories();
        loadBucketList();
        loadLetters();
        loadStickyNotes();
        loadCalendarEvents();
        loadPlaces();
        break;
    }
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

      // Connect WebSockets with full real-time couple synchronization
      _socketService.connect(
        userId: userId,
        coupleId: _coupleData!['id'],
        onHeartbeatReceived: (data) {
          final sender = data['senderName'] ?? 'Tu pareja';
          triggerHeartbeatReceived(sender);
          _notificationService.showNotification(
            title: '💓 ¡Latido de Amor Recibido!',
            body: '$sender te acaba de enviar un toque de amor.',
          );
        },
        onPartnerMoodUpdated: (data) {
          final mood = data['moodStatus'] ?? '';
          final icon = data['moodIcon'] ?? '🥰';
          onPartnerMood(mood, icon);
          _notificationService.showNotification(
            title: '$icon Estado de Ánimo',
            body: 'Tu pareja ahora se siente: $mood',
          );
        },
        onPartnerPresence: (data) {
          onPartnerOnline(data['is_online'] ?? false);
        },
        onPartnerRefresh: (data) {
          _handlePartnerRefresh(data['type']);
        },
      );

      // Load all feature data from backend
      loadTodayQuestion();
      loadMemories();
      loadBucketList();
      loadLetters();
      loadStickyNotes();
      loadCalendarEvents();
      loadPlaces();
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

  // Anniversary Update Method
  Future<bool> updateAnniversaryDate(DateTime picked) async {
    final dateStr = picked.toIso8601String().split('T').first;
    if (_coupleData != null) {
      _coupleData!['anniversary_date'] = dateStr;
      _coupleData!['relationship_time_start'] = picked.toIso8601String();
    } else {
      _coupleData = {
        'anniversary_date': dateStr,
        'relationship_time_start': picked.toIso8601String(),
      };
    }
    _startLoveTicker();
    notifyListeners();

    try {
      final res = await _apiService.patch('/couple/settings', {
        'anniversary_date': dateStr,
      });
      if (res['couple'] != null) {
        _coupleData = res['couple'];
        _startLoveTicker();
      }
      if (_coupleData?['id'] != null && _coupleData?['id'] != 'demo-couple-1') {
        _socketService.emitDataChanged(coupleId: _coupleData!['id'], type: 'all');
      }
      return true;
    } catch (e) {
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
  Future<void> loadTodayQuestion({bool random = false, String? questionId}) async {
    if (_coupleData?['id'] == 'demo-couple-1') return;

    _isLoadingQuestion = true;
    notifyListeners();

    try {
      String endpoint = '/questions/today';
      if (questionId != null) {
        endpoint = '/questions/today?question_id=$questionId';
      } else if (random) {
        endpoint = '/questions/today?random=true';
      }
      final res = await _apiService.get(endpoint);
      _todayQuestion = res;
    } catch (e) {
      print('Error cargando pregunta: $e');
    }

    _isLoadingQuestion = false;
    notifyListeners();
  }

  Future<void> loadAnswerHistory() async {
    if (_coupleData?['id'] == 'demo-couple-1') return;
    try {
      final res = await _apiService.get('/questions/history');
      _questionHistory = res['history'] ?? [];
      notifyListeners();
    } catch (e) {
      print('Error cargando historial de preguntas: $e');
    }
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
      if (_coupleData?['id'] != null && _coupleData?['id'] != 'demo-couple-1') {
        _socketService.emitDataChanged(coupleId: _coupleData!['id'], type: 'question');
      }
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
    List<String>? photoUrls,
  }) async {
    if (_coupleData?['id'] == 'demo-couple-1') {
      _memories.insert(0, {
        'id': 'demo-m-${DateTime.now().millisecondsSinceEpoch}',
        'title': title,
        'description': description ?? '',
        'memory_date': memoryDate,
        'location_name': locationName,
        'photo_urls': photoUrls ?? [],
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
        'photo_urls': photoUrls ?? [],
      });
      await loadMemories();
      await fetchCoupleStatus();
      if (_coupleData?['id'] != null && _coupleData?['id'] != 'demo-couple-1') {
        _socketService.emitDataChanged(coupleId: _coupleData!['id'], type: 'memories');
      }
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
      if (_coupleData?['id'] != null && _coupleData?['id'] != 'demo-couple-1') {
        _socketService.emitDataChanged(coupleId: _coupleData!['id'], type: 'bucket');
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleBucketItem(String itemId, bool isCompleted, {String? proofPhotoUrl}) async {
    if (_coupleData?['id'] == 'demo-couple-1') {
      final index = _bucketList.indexWhere((item) => item['id'] == itemId);
      if (index != -1) {
        _bucketList[index]['is_completed'] = isCompleted;
        if (proofPhotoUrl != null) _bucketList[index]['proof_photo_url'] = proofPhotoUrl;
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
        if (proofPhotoUrl != null) 'proof_photo_url': proofPhotoUrl,
      });
      await loadBucketList();
      await fetchCoupleStatus();
      if (_coupleData?['id'] != null && _coupleData?['id'] != 'demo-couple-1') {
        _socketService.emitDataChanged(coupleId: _coupleData!['id'], type: 'bucket');
      }
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
      if (_coupleData?['id'] != null && _coupleData?['id'] != 'demo-couple-1') {
        _socketService.emitDataChanged(coupleId: _coupleData!['id'], type: 'letters');
      }
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
