// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'openai_responses_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenAiResponseStreamDto _$OpenAiResponseStreamDtoFromJson(
  Map<String, dynamic> json,
) => OpenAiResponseStreamDto(
  type: json['type'] as String,
  delta: json['delta'] as String?,
);

Map<String, dynamic> _$OpenAiResponseStreamDtoToJson(
  OpenAiResponseStreamDto instance,
) => <String, dynamic>{'type': instance.type, 'delta': instance.delta};
