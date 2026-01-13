// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'openai_models_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenAiModelDto _$OpenAiModelDtoFromJson(Map<String, dynamic> json) =>
    OpenAiModelDto(
      id: json['id'] as String,
      ownedBy: json['owned_by'] as String?,
      created: (json['created'] as num?)?.toInt(),
    );

Map<String, dynamic> _$OpenAiModelDtoToJson(OpenAiModelDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'owned_by': instance.ownedBy,
      'created': instance.created,
    };

OpenAiModelsResponseDto _$OpenAiModelsResponseDtoFromJson(
  Map<String, dynamic> json,
) => OpenAiModelsResponseDto(
  data: (json['data'] as List<dynamic>)
      .map((e) => OpenAiModelDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$OpenAiModelsResponseDtoToJson(
  OpenAiModelsResponseDto instance,
) => <String, dynamic>{'data': instance.data};
