class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  factory AppException.noInternet() => AppException(
        message: 'No internet connection. Please check your network.',
        code: 'NO_INTERNET',
      );

  factory AppException.apiFailure(String detail) => AppException(
        message: 'Service unavailable: $detail',
        code: 'API_FAILURE',
      );

  factory AppException.permissionDenied(String permission) => AppException(
        message: '$permission permission denied. Please enable in settings.',
        code: 'PERMISSION_DENIED',
      );

  factory AppException.invalidInput(String field) => AppException(
        message: 'Invalid input for $field. Please check and try again.',
        code: 'INVALID_INPUT',
      );

  factory AppException.notFound() => AppException(
        message: 'No results found. Try different parameters.',
        code: 'NOT_FOUND',
      );

  @override
  String toString() => 'AppException: $message (code: $code)';
}
