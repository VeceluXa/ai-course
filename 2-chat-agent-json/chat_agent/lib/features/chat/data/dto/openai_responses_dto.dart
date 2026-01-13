import 'package:json_annotation/json_annotation.dart';

part 'openai_responses_dto.g.dart';

@JsonSerializable()
class OpenAiResponseStreamDto {
  const OpenAiResponseStreamDto({required this.type, this.delta});

  final String type;
  final String? delta;

  factory OpenAiResponseStreamDto.fromJson(Map<String, dynamic> json) =>
      _$OpenAiResponseStreamDtoFromJson(json);
  Map<String, dynamic> toJson() => _$OpenAiResponseStreamDtoToJson(this);
}
