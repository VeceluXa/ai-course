import 'failure.dart';

class AppException implements Exception {
  final FailureType type;
  final String message;

  const AppException(this.type, this.message);

  Failure toFailure() => Failure(type, message);

  @override
  String toString() => 'AppException($type, $message)';
}
