import 'package:certificat4/core/errors/exceptions.dart';
import 'package:certificat4/core/storage/hive_service.dart';
import 'package:certificat4/features/posts/domain/entities/post.dart';
import 'package:dio/dio.dart';

abstract class PostRepository {
  Future<List<Post>> getPosts();
}

class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl({required this.dio});

  final Dio dio;
  static const _cacheKey = 'cached_posts';

  @override
  Future<List<Post>> getPosts() async {
    try {
      final response = await dio.get(
        '/posts',
        queryParameters: {'limit': 10},
        options: Options(headers: {'Accept': 'application/json'}),
      );

      final list = response.data is Map ? response.data['posts'] as List? ?? [] : <dynamic>[];
      final posts = list.map((item) => Post.fromMap(Map<String, dynamic>.from(item))).toList();
      await HiveService.instance.putJson(_cacheKey, list);
      return posts;
    } on DioException catch (e) {
      final cached = HiveService.instance.getJson(_cacheKey);
      if (cached is List && cached.isNotEmpty) {
        return cached.map((item) => Post.fromMap(Map<String, dynamic>.from(item))).toList();
      }
      throw NetworkException.fromDio(e, fallback: 'Impossible de charger les publications.');
    }
  }
}
