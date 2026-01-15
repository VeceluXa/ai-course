enum FailureType {
  unauthorized,
  forbidden,
  rateLimit,
  network,
  timeout,
  storage,
  validation,
  unknown,
}

class Failure implements Exception {
  final FailureType type;
  final String message;

  const Failure(this.type, this.message);

  @override
  String toString() => 'Failure($type, $message)';
}
