import 'package:dio/dio.dart';

class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException(String message) : super(message);

  factory NetworkException.fromDio(DioException error, {required String fallback}) {
    final statusCode = error.response?.statusCode;
    final message = statusCode != null && statusCode >= 500
        ? 'Le service est temporairement indisponible.'
        : switch (statusCode) {
          401 => 'Votre session a expiré. Veuillez vous reconnecter.',
          403 => 'Vous n’êtes pas autorisé à consulter ces données.',
          _ => switch (error.type) {
          DioExceptionType.connectionTimeout ||
          DioExceptionType.receiveTimeout ||
          DioExceptionType.sendTimeout => 'Le délai de connexion est dépassé.',
          DioExceptionType.connectionError => 'Connexion impossible. Vérifiez votre réseau.',
          _ => fallback,
          },
        };
    return NetworkException(message);
  }
}

class UnauthorizedException extends AppException {
  const UnauthorizedException() : super('Session expirée. Veuillez vous reconnecter.');
}

class CacheException extends AppException {
  const CacheException(String message) : super(message);
}
