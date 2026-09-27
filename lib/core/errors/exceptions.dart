class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException(String message) : super(message);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException() : super('Session expirée. Veuillez vous reconnecter.');
}

class CacheException extends AppException {
  const CacheException(String message) : super(message);
}
