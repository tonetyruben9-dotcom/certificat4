import 'package:certificat4/features/auth/domain/entities/user_session.dart';

abstract class AuthRepository {
  Future<UserSession> login(String username, String password);
  Future<UserSession> register(String username, String email, String password);
  Future<UserSession?> getSavedSession();
  Future<void> saveSession(UserSession session);
  Future<void> clearSession();
}
