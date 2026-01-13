class SettingsState {
  static const Object _unset = Object();

  final bool isLoading;
  final bool isValidating;
  final String? apiKey;
  final String? errorMessage;
  final String? successMessage;

  const SettingsState({
    required this.isLoading,
    required this.isValidating,
    required this.apiKey,
    required this.errorMessage,
    required this.successMessage,
  });

  factory SettingsState.initial() {
    return const SettingsState(
      isLoading: true,
      isValidating: false,
      apiKey: null,
      errorMessage: null,
      successMessage: null,
    );
  }

  bool get hasKey => apiKey != null && apiKey!.isNotEmpty;

  SettingsState copyWith({
    bool? isLoading,
    bool? isValidating,
    Object? apiKey = _unset,
    Object? errorMessage = _unset,
    Object? successMessage = _unset,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      isValidating: isValidating ?? this.isValidating,
      apiKey: apiKey == _unset ? this.apiKey : apiKey as String?,
      errorMessage: errorMessage == _unset ? this.errorMessage : errorMessage as String?,
      successMessage: successMessage == _unset ? this.successMessage : successMessage as String?,
    );
  }
}
