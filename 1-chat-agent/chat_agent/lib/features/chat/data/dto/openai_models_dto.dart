import 'package:json_annotation/json_annotation.dart';

part 'openai_models_dto.g.dart';

@JsonSerializable()
class OpenAiModelDto {
  const OpenAiModelDto({required this.id, this.ownedBy, this.created});

  final String id;
  @JsonKey(name: 'owned_by')
  final String? ownedBy;
  final int? created;

  factory OpenAiModelDto.fromJson(Map<String, dynamic> json) => _$OpenAiModelDtoFromJson(json);
  Map<String, dynamic> toJson() => _$OpenAiModelDtoToJson(this);
}

@JsonSerializable()
class OpenAiModelsResponseDto {
  const OpenAiModelsResponseDto({required this.data});

  final List<OpenAiModelDto> data;

  factory OpenAiModelsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$OpenAiModelsResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$OpenAiModelsResponseDtoToJson(this);
}
