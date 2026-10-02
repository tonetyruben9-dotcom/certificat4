import 'package:certificat4/core/errors/exceptions.dart';
import 'package:certificat4/core/storage/hive_service.dart';
import 'package:certificat4/features/users/domain/entities/app_user.dart';
import 'package:dio/dio.dart';

abstract class UserRepository {
  Future<List<AppUser>> getUsers();
}

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({required this.dio});

  final Dio dio;
  static const _cacheKey = 'cached_users';

  @override
  Future<List<AppUser>> getUsers() async {
    try {
      final response = await dio.get(
        '/users',
        queryParameters: {'limit': 10},
        options: Options(headers: {'Accept': 'application/json'}),
      );
      final list = response.data is Map ? response.data['users'] as List? ?? [] : <dynamic>[];
      final users = list.map((item) => AppUser.fromMap(Map<String, dynamic>.from(item))).toList();
      await HiveService.instance.putJson(_cacheKey, list);
      return users;
    } on DioException catch (error) {
      final cached = HiveService.instance.getJson(_cacheKey);
      if (cached is List && cached.isNotEmpty) {
        return cached.map((item) => AppUser.fromMap(Map<String, dynamic>.from(item))).toList();
      }
      throw NetworkException.fromDio(error, fallback: 'Impossible de charger les utilisateurs.');
    }
  }
}