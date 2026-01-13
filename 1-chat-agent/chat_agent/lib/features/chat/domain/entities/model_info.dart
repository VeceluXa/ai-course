import 'package:freezed_annotation/freezed_annotation.dart';

part 'model_info.freezed.dart';

@freezed
class ModelInfo with _$ModelInfo {
  const factory ModelInfo({
    required String id,
    required String displayName,
  }) = _ModelInfo;
}
