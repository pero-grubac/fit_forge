class AppException implements Exception {
  final String userMessage;
  final String? technicalMessage;
  final StackTrace? stackTrace;

  const AppException({
    required this.userMessage,
    this.technicalMessage,
    this.stackTrace,
  });

  @override
  String toString() => technicalMessage ?? userMessage;
}