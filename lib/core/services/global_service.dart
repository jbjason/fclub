import 'package:fclub/feature/auth/data/model/auth_user.dart';
import 'package:hive_flutter/hive_flutter.dart';

class GlobalService {
  GlobalService._();

  static final GlobalService instance = GlobalService._();
  static const String _authBoxName = 'auth_session';
  static const String _currentUserKey = 'current_user';

  Box<dynamic>? _authBox;
  AuthUser? _currentUser;
  String? _idToken;

  AuthUser? get currentUser => _currentUser;
  String? get idToken => _idToken;

  Future<void> initialize() async {
    await Hive.initFlutter();
    _authBox = await Hive.openBox<dynamic>(_authBoxName);

    final cachedUser = _authBox?.get(_currentUserKey);
    if (cachedUser is Map) {
      _currentUser = AuthUser.fromMap(Map<String, dynamic>.from(cachedUser));
    }
  }

  Future<void> setSession({required AuthUser user, String? idToken}) async {
    _currentUser = user;
    _idToken = idToken;
    await _authBox?.put(_currentUserKey, user.toMap());
  }

  void clearFirebaseSession() {
    _currentUser = null;
    _idToken = null;
  }

  Future<void> clearSession() async {
    clearFirebaseSession();
    await _authBox?.delete(_currentUserKey);
  }
}
