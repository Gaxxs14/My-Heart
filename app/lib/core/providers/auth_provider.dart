import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final SocketService _socketService = SocketService();

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _currentUser;
  Map<String, dynamic>? _partnerUser;
  bool _isAuthenticated = false;

  bool get isLoading       => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get currentUser  => _currentUser;
  Map<String, dynamic>? get partnerUser  => _partnerUser;
  bool get isAuthenticated => _isAuthenticated;
  String? get coupleId     => _currentUser?['couple_id'];
  bool get isPaired        => coupleId != null;

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    await _apiService.init();
    if (_apiService.token != null) {
      try {
        final res = await _apiService.get('/auth/profile');
        _currentUser = res['profile'];
        _partnerUser = {
          'id':                     res['profile']['partner_user_id'],
          'name':                   res['profile']['partner_name'],
          'nickname':               res['profile']['partner_nickname'],
          'avatar_url':             res['profile']['partner_avatar_url'],
          'mood_status':            res['profile']['partner_mood_status'],
          'mood_icon':              res['profile']['partner_mood_icon'],
          'is_online':              res['profile']['partner_is_online'],
          'favorite_song_title':    res['profile']['partner_favorite_song_title'],
          'favorite_song_artist':   res['profile']['partner_favorite_song_artist'],
          'favorite_song_url':      res['profile']['partner_favorite_song_url'],
          'favorite_song_lyrics':   res['profile']['partner_favorite_song_lyrics'],
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
    required String username,
    String? name,
    String? nickname,
    String? email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.post('/auth/register', {
        'username': username.trim(),
        'name':     (name?.isNotEmpty == true ? name : nickname ?? username).toString().trim(),
        'nickname': (nickname?.isNotEmpty == true ? nickname : name ?? username).toString().trim(),
        'email':    email?.trim(),
        'password': password,
      });

      await _apiService.setToken(res['token']);
      _currentUser     = res['user'];
      _isAuthenticated = true;
      _isLoading       = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading    = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.post('/auth/login', {
        'username': username.trim(),
        'password': password,
      });

      await _apiService.setToken(res['token']);
      _currentUser     = res['user'];
      _isAuthenticated = true;

      await checkAuthStatus();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading    = false;
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
        'name':     name,
        'nickname': nickname,
      });

      await _apiService.setToken(res['token']);
      _currentUser     = res['user'];
      _isAuthenticated = true;
      _isLoading       = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading    = false;
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
        'name':             name,
        'nickname':         nickname,
        'pairing_code':     pairingCode,
        'anniversary_date': anniversaryDate?.toIso8601String().split('T').first,
      });

      await _apiService.setToken(res['token']);
      _currentUser     = res['user'];
      _isAuthenticated = true;
      await checkAuthStatus();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading    = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? nickname,
    String? avatarUrl,
    String? favoriteSongTitle,
    String? favoriteSongArtist,
    String? favoriteSongUrl,
    String? favoriteSongLyrics,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _apiService.patch('/auth/profile', {
        if (name != null) 'name': name.trim(),
        if (nickname != null) 'nickname': nickname.trim(),
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (favoriteSongTitle != null) 'favorite_song_title': favoriteSongTitle.trim(),
        if (favoriteSongArtist != null) 'favorite_song_artist': favoriteSongArtist.trim(),
        if (favoriteSongUrl != null) 'favorite_song_url': favoriteSongUrl.trim(),
        if (favoriteSongLyrics != null) 'favorite_song_lyrics': favoriteSongLyrics.trim(),
      });

      if (res['user'] != null) {
        _currentUser = res['user'];
      }
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
        'mood_icon':   moodIcon,
      });
      if (_currentUser != null) {
        _currentUser!['mood_status'] = moodStatus;
        _currentUser!['mood_icon']   = moodIcon;
        notifyListeners();

        if (coupleId != null && coupleId != 'demo-couple-1') {
          _socketService.sendMoodChange(
            coupleId: coupleId!,
            userId: _currentUser!['id'] ?? '',
            moodStatus: moodStatus,
            moodIcon: moodIcon,
          );
        }
      }
    } catch (e) {
      debugPrint('Error al actualizar estado de ánimo: $e');
    }
  }

  void updatePartnerMood(String moodStatus, String moodIcon) {
    if (_partnerUser != null) {
      _partnerUser!['mood_status'] = moodStatus;
      _partnerUser!['mood_icon']   = moodIcon;
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
    _currentUser     = null;
    _partnerUser     = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<bool> deleteAccount() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.delete('/auth/delete-account');
      await _apiService.setToken(null);
      _currentUser     = null;
      _partnerUser     = null;
      _isAuthenticated = false;
      _isLoading       = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading    = false;
      notifyListeners();
      return false;
    }
  }
}
