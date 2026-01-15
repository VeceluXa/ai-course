class SettingsState {
  static const Object _unset = Object();

  final bool isLoading;
  final bool isValidating;
  final bool isSavingPrompt;
  final String? apiKey;
  final String? systemPrompt;
  final String? errorMessage;
  final String? successMessage;

  const SettingsState({
    required this.isLoading,
    required this.isValidating,
    required this.isSavingPrompt,
    required this.apiKey,
    required this.systemPrompt,
    required this.errorMessage,
    required this.successMessage,
  });

  factory SettingsState.initial() {
    return const SettingsState(
      isLoading: true,
      isValidating: false,
      isSavingPrompt: false,
      apiKey: null,
      systemPrompt: null,
      errorMessage: null,
      successMessage: null,
    );
  }

  bool get hasKey => apiKey != null && apiKey!.isNotEmpty;

  SettingsState copyWith({
    bool? isLoading,
    bool? isValidating,
    bool? isSavingPrompt,
    Object? apiKey = _unset,
    Object? systemPrompt = _unset,
    Object? errorMessage = _unset,
    Object? successMessage = _unset,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      isValidating: isValidating ?? this.isValidating,
      isSavingPrompt: isSavingPrompt ?? this.isSavingPrompt,
      apiKey: apiKey == _unset ? this.apiKey : apiKey as String?,
      systemPrompt: systemPrompt == _unset ? this.systemPrompt : systemPrompt as String?,
      errorMessage: errorMessage == _unset ? this.errorMessage : errorMessage as String?,
      successMessage: successMessage == _unset ? this.successMessage : successMessage as String?,
    );
  }
}
