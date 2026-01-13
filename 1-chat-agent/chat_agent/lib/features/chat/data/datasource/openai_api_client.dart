import 'package:dio/dio.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/chat_message.dart';
import '../dto/openai_models_dto.dart';
import 'openai_sse_parser.dart';

class OpenAiApiClient {
  OpenAiApiClient({
    required Dio dio,
    required OpenAiSseParser sseParser,
    AppLogger? logger,
  })  : _dio = dio,
        _sseParser = sseParser,
        _logger = logger;

  final Dio _dio;
  final OpenAiSseParser _sseParser;
  final AppLogger? _logger;

  Future<List<OpenAiModelDto>> listModels() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/models');
      final data = OpenAiModelsResponseDto.fromJson(response.data ?? const {});
      return data.data;
    } on DioException catch (error) {
      throw _mapDioError(error);
    } catch (_) {
      throw const Failure(FailureType.unknown, 'Unable to load models.');
    }
  }

  Stream<String> streamResponse({
    required List<ChatMessage> messages,
    required String modelId,
    required CancelToken cancelToken,
  }) async* {
    try {
      final response = await _dio.post<ResponseBody>(
        '/responses',
        data: {
          'model': modelId,
          'stream': true,
          'input': messages.map(_toOpenAiMessage).toList(),
        },
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Accept': 'text/event-stream'},
        ),
        cancelToken: cancelToken,
      );
      final stream = response.data?.stream;
      if (stream == null) {
        throw const Failure(FailureType.unknown, 'Empty response stream.');
      }
      _logger?.logInfo('[SSE] stream opened for model=$modelId');
      yield* _sseParser.parse(stream);
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) {
        _logger?.logWarning('[SSE] stream cancelled');
        return;
      }
      _logger?.logError(error, error.requestOptions.uri, error.stackTrace);
      throw _mapDioError(error);
    } catch (_) {
      throw const Failure(FailureType.unknown, 'Unable to stream response.');
    }
  }

  Map<String, dynamic> _toOpenAiMessage(ChatMessage message) {
    final type = message.role == ChatRole.assistant ? 'output_text' : 'input_text';
    return {
      'role': message.role.name,
      'content': [
        {
          'type': type,
          'text': message.content,
        },
      ],
    };
  }

  Failure _mapDioError(DioException error) {
    final response = error.response;
    final statusCode = response?.statusCode ?? 0;
    if (statusCode == 401) {
      return const Failure(FailureType.unauthorized, 'Invalid API key. Please update it in Settings.');
    }
    if (statusCode == 403) {
      return const Failure(FailureType.forbidden, 'This model is not available. Please pick another model.');
    }
    if (statusCode == 429) {
      return const Failure(FailureType.rateLimit, 'Rate limit exceeded. Please try again later.');
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const Failure(FailureType.timeout, 'Request timed out. Check your connection and retry.');
    }
    if (error.type == DioExceptionType.connectionError) {
      return const Failure(FailureType.network, 'No internet connection.');
    }
    return const Failure(FailureType.unknown, 'Unexpected error. Please try again.');
  }
}

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._apiKeyProvider);

  final Future<String?> Function() _apiKeyProvider;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final apiKey = await _apiKeyProvider();
    if (apiKey != null && apiKey.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $apiKey';
    }
    options.headers['Content-Type'] = 'application/json';
    handler.next(options);
  }
}

class LoggingInterceptor extends Interceptor {
  LoggingInterceptor(this._logger);

  final AppLogger _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.logRequest(options.method, options.uri, options.headers);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.logResponse(response.statusCode ?? 0, response.requestOptions.uri);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.logError(err, err.requestOptions.uri);
    handler.next(err);
  }
}
