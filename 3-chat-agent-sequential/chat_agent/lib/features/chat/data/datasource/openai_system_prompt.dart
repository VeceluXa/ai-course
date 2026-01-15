import '../../../../core/config/system_prompt.dart';

const Map<String, dynamic> defaultModelParameters = {'temperature': 0.2};

String buildOpenAiSystemPrompt({String? override}) {
  final resolved = override?.trim();
  if (resolved == null || resolved.isEmpty) {
    return defaultSystemPrompt;
  }
  return resolved;
}
