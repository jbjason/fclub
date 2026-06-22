import 'package:fclub/feature/auth/data/model/auth_user.dart';
import 'package:hive_flutter/hive_flutter.dart';

class GlobalService {
  GlobalService._();

  static final GlobalService instance = GlobalService._();
  static const String _authBoxName = 'auth_session';
  static const String _meResponseKey = 'me_response';

  Box<dynamic>? _authBox;
  AuthUser? _currentUser;
  String? _idToken;

  AuthUser? get currentUser => _currentUser;
  String? get idToken => _idToken;

  Future<void> initialize() async {
    await Hive.initFlutter();
    _authBox = await Hive.openBox<dynamic>(_authBoxName);
  }

  void setSession({required AuthUser user, String? idToken}) {
    _currentUser = user;
    _idToken = idToken;
  }

  void clearFirebaseSession() {
    _currentUser = null;
    _idToken = null;
  }

  Future<void> clearSession() async {
    clearFirebaseSession();
    await _authBox?.delete(_meResponseKey);
  }
}
