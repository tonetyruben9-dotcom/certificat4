import 'package:dio/dio.dart';
import 'package:certificat4/core/storage/hive_service.dart';

class AppDio {
  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://dummyjson.com',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final session = HiveService.instance.getJson('session');
          final token = session is Map ? session['token'] : null;
          if (token != null && token.toString().isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final session = HiveService.instance.getJson('session');
            if (session != null) {
              await HiveService.instance.clear();
            }
          }
          handler.next(error);
        },
      ),
    );

    return dio;
  }
}
