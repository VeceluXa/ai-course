String redactAuthorization(String? value) {
  if (value == null || value.isEmpty) return '';
  return 'Bearer ***';
}

Map<String, dynamic> redactHeaders(Map<String, dynamic> headers) {
  final redacted = <String, dynamic>{};
  for (final entry in headers.entries) {
    if (entry.key.toLowerCase() == 'authorization') {
      redacted[entry.key] = redactAuthorization(entry.value?.toString());
    } else {
      redacted[entry.key] = entry.value;
    }
  }
  return redacted;
}
