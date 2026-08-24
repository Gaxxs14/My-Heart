import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _currentUser;
  Map<String, dynamic>? _partnerUser;
  bool _isAuthenticated = false;
  bool _isDemoMode = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get currentUser => _currentUser;
  Map<String, dynamic>? get partnerUser => _partnerUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isDemoMode => _isDemoMode;
  String? get coupleId => _currentUser?['couple_id'];
  bool get isPaired => coupleId != null;

  void enterDemoMode({String name = 'Gabriel', String? nickname}) {
    _isDemoMode = true;
    _isAuthenticated = true;
    _currentUser = {
      'id': 'demo-user-1',
      'name': name,
      'nickname': nickname?.isNotEmpty == true ? nickname : 'Mi Amor',
      'mood_status': 'Pensando en ti 💭',
      'mood_icon': '💭',
      'couple_id': 'demo-couple-1',
      'avatar_url': null,
    };
    _partnerUser = {
      'id': 'demo-user-2',
      'name': 'Mi Amor',
      'nickname': 'Princesa 🥰',
      'mood_status': 'Enamorada 🥰',
      'mood_icon': '🥰',
      'is_online': true,
      'avatar_url': null,
    };
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    await _apiService.init();
    if (_apiService.token != null) {
      try {
        final res = await _apiService.get('/auth/profile');
        _currentUser = res['profile'];
        _partnerUser = {
          'id': res['profile']['partner_user_id'],
          'name': res['profile']['partner_name'],
          'nickname': res['profile']['partner_nickname'],
          'avatar_url': res['profile']['partner_avatar_url'],
          'mood_status': res['profile']['partner_mood_status'],
          'mood_icon': res['profile']['partner_mood_icon'],
          'is_online': res['profile']['partner_is_online'],
        };
        _isAuthenticated = true;
      } catch (e) {
        await _apiService.setToken(null);
        _isAuthenticated = false;
      }
    } else {
      _isAuthenticated = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? nickname,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.post('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
        'nickname': nickname,
      });

      await _apiService.setToken(res['token']);
      _currentUser = res['user'];
      _isAuthenticated = true;
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

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      await _apiService.setToken(res['token']);
      _currentUser = res['user'];
      _isAuthenticated = true;

      // Also fetch full profile
      await checkAuthStatus();

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

  Future<bool> quickStart({
    required String name,
    String? nickname,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.post('/auth/quick-start', {
        'name': name,
        'nickname': nickname,
      });

      await _apiService.setToken(res['token']);
      _currentUser = res['user'];
      _isAuthenticated = true;
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

  Future<bool> quickLink({
    required String name,
    required String pairingCode,
    String? nickname,
    DateTime? anniversaryDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.post('/auth/quick-link', {
        'name': name,
        'nickname': nickname,
        'pairing_code': pairingCode,
        'anniversary_date': anniversaryDate?.toIso8601String().split('T').first,
      });

      await _apiService.setToken(res['token']);
      _currentUser = res['user'];
      _isAuthenticated = true;
      await checkAuthStatus();
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

  Future<void> updateMood(String moodStatus, String moodIcon) async {
    try {
      await _apiService.patch('/auth/mood', {
        'mood_status': moodStatus,
        'mood_icon': moodIcon,
      });
      if (_currentUser != null) {
        _currentUser!['mood_status'] = moodStatus;
        _currentUser!['mood_icon'] = moodIcon;
        notifyListeners();
      }
    } catch (e) {
      print('Error al actualizar estado de ánimo: $e');
    }
  }

  void updatePartnerMood(String moodStatus, String moodIcon) {
    if (_partnerUser != null) {
      _partnerUser!['mood_status'] = moodStatus;
      _partnerUser!['mood_icon'] = moodIcon;
      notifyListeners();
    }
  }

  void updatePartnerPresence(bool isOnline) {
    if (_partnerUser != null) {
      _partnerUser!['is_online'] = isOnline;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _apiService.setToken(null);
    _currentUser = null;
    _partnerUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
