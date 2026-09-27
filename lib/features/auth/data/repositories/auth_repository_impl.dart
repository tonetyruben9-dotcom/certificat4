import 'package:certificat4/core/errors/exceptions.dart';
import 'package:certificat4/core/storage/hive_service.dart';
import 'package:certificat4/features/auth/domain/entities/user_session.dart';
import 'package:certificat4/features/auth/domain/repositories/auth_repository.dart';
import 'package:dio/dio.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this.dio});

  final Dio dio;

  @override
  Future<UserSession> login(String username, String password) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {'username': username, 'password': password},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final session = UserSession.fromMap(Map<String, dynamic>.from(response.data));
        return session;
      }
      throw const AppException('Connexion impossible');
    } on DioException catch (e) {
      throw AppException(e.response?.data['message'] ?? 'Connexion impossible');
    }
  }

  @override
  Future<UserSession> register(String username, String email, String password) async {
    try {
      final response = await dio.post(
        '/users/add',
        data: {'username': username, 'email': email, 'password': password},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = Map<String, dynamic>.from(response.data);
        return UserSession(
          id: data['id'] ?? 0,
          username: data['username'] ?? username,
          email: data['email'] ?? email,
          firstName: '',
          lastName: '',
          gender: '',
          image: '',
          token: data['token'] ?? 'demo-token',
        );
      }
      throw const AppException('Inscription impossible');
    } on DioException catch (e) {
      throw AppException(e.response?.data['message'] ?? 'Inscription impossible');
    }
  }

  @override
  Future<UserSession?> getSavedSession() async {
    final session = HiveService.instance.getJson('session');
    if (session is Map) {
      return UserSession.fromMap(Map<String, dynamic>.from(session));
    }
    return null;
  }

  @override
  Future<void> saveSession(UserSession session) async {
    await HiveService.instance.putJson('session', session.toMap());
  }

  @override
  Future<void> clearSession() async {
    await HiveService.instance.clear();
  }
}
