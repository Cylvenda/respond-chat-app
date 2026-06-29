import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';

class ApiException implements Exception {
  final String message;
  final String? code;

  ApiException({required this.message, this.code});

  @override
  String toString() =>
      'ApiException: $message${code != null ? ' (Code: $code)' : ''}';
}

class ChatApiService {
  final GeminiChatSession _chatSession;

  ChatApiService() : _chatSession = GeminiChatSession.fromEnv();

  Future<String> sendMessage(
    String userMessage, {
    List<Map<String, dynamic>>? conversationHistory,
  }) async {
    return await _chatSession.sendMessage(
      userMessage,
      conversationHistory: conversationHistory,
    );
  }
}

class GeminiChatSession {
  static const String _systemPrompt =
      'You are CyberGuard, a helpful cybersecurity awareness chatbot. '
      'You provide expert advice on cybersecurity topics including phishing prevention, '
      'password security, malware protection, data privacy, and secure practices. '
      'Keep responses concise, practical, and actionable.';

  final String _apiKey;
  final bool _useBearerToken;
  final Uri _apiEndpoint;
  final Duration _timeout;

  GeminiChatSession._(
    this._apiKey,
    this._useBearerToken,
    this._apiEndpoint,
    this._timeout,
  );

  factory GeminiChatSession.fromEnv() {
    final apiKey = dotenv.get('GEMINI_API_KEY', fallback: '');
    if (apiKey.isEmpty) {
      throw ApiException(
        message: 'GEMINI_API_KEY is not configured in .env file',
        code: 'CONFIG_ERROR',
      );
    }

    final authType = dotenv
        .get('GEMINI_AUTH_TYPE', fallback: 'key')
        .toLowerCase();
    final useBearerToken = authType == 'bearer';

    // if (useBearerToken && !apiKey.startsWith('ya29')) {
    //   print(
    //     'Warning: GEMINI_AUTH_TYPE=Bearer is set, but GEMINI_API_KEY does not look like an OAuth access token.',
    //   );
    // }

    final model = dotenv.get('GEMINI_MODEL', fallback: 'gemini-2.5-flash');
    final apiBaseUrl = dotenv.get('GEMINI_API_ENDPOINT', fallback: '');
    final endpoint = apiBaseUrl.isNotEmpty
        ? Uri.parse(apiBaseUrl)
        : Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
          );

    final timeoutSeconds =
        int.tryParse(dotenv.get('API_TIMEOUT_SECONDS', fallback: '30')) ?? 30;
    final timeout = Duration(seconds: timeoutSeconds);

    // print(
    //   'GeminiChatSession initialized: endpoint=$endpoint timeout=${timeout.inSeconds}s auth=${useBearerToken ? 'Bearer' : 'Key'}',
    // );

    return GeminiChatSession._(apiKey, useBearerToken, endpoint, timeout);
  }

  Future<String> sendMessage(
    String prompt, {
    List<Map<String, dynamic>>? conversationHistory,
  }) async {
    final uri = _buildUri();
    final headers = _buildHeaders();
    final body = _buildRequestBody(prompt, conversationHistory);

    // print('GeminiChatSession sending request to $_sanitizedUri');
    // print('GeminiChatSession request headers: $headers');
    // print('GeminiChatSession request body: $body');

    try {
      final response = await http
          .post(uri, headers: headers, body: body)
          .timeout(
            _timeout,
            onTimeout: () {
              throw ApiException(
                message:
                    'API request timed out after ${_timeout.inSeconds} seconds',
                code: 'TIMEOUT',
              );
            },
          );

      // print('GeminiChatSession response status: ${response.statusCode}');
      // print('GeminiChatSession response body: ${response.body}');

      return _parseResponse(response);
    } on TimeoutException catch (_) {
      throw ApiException(
        message: 'Request timed out. The service is taking too long to respond.',
        code: 'TIMEOUT',
      );
    } catch (e) {
      final sanitized = _redactUri(e.toString());
      final message = e is http.ClientException
          ? 'Network error. Please check your internet connection and try again. ($sanitized)'
          : e is SocketException
              ? 'No internet connection. Please check your network and try again. ($sanitized)'
              : 'Request failed: $sanitized';
      throw ApiException(
        message: message,
        code: 'REQUEST_ERROR',
      );
    }
  }

  String _redactUri(String? input) {
    if (input == null || input.isEmpty) return 'unknown error';
    if (_useBearerToken || _apiKey.isEmpty) return input;
    final escaped = RegExp.escape(_apiKey);
    return input.replaceAll(RegExp(escaped), '***REDACTED***');
  }

  Uri _buildUri() {
    if (_useBearerToken) {
      return _apiEndpoint;
    }

    final queryParameters = Map<String, String>.from(
      _apiEndpoint.queryParameters,
    );
    queryParameters['key'] = _apiKey;
    return _apiEndpoint.replace(queryParameters: queryParameters);
  }

  Map<String, String> _buildHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_useBearerToken) {
      headers['Authorization'] = 'Bearer $_apiKey';
    }
    return headers;
  }

  String _buildRequestBody(
    String prompt,
    List<Map<String, dynamic>>? conversationHistory,
  ) {
    final contents = <Map<String, dynamic>>[];

    if (conversationHistory != null && conversationHistory.isNotEmpty) {
      for (final message in conversationHistory) {
        final role = message['role'] as String? ?? 'user';
        final content = message['content'] as String? ?? '';
        final geminiRole = role == 'assistant' ? 'model' : 'user';

        contents.add({
          'role': geminiRole,
          'parts': [
            {'text': content},
          ],
        });
      }
    }

    contents.add({
      'role': 'user',
      'parts': [
        {'text': prompt},
      ],
    });

    final body = <String, dynamic>{
      'contents': contents,
      'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 512},
    };

    body['systemInstruction'] = {
      'parts': [
        {'text': _systemPrompt},
      ],
    };

    return jsonEncode(body);
  }

  String _parseResponse(http.Response response) {
    if (response.statusCode != 200) {
      final apiMessage = _extractApiErrorMessage(response.body);
      final friendlyMessage = _mapApiErrorToFriendlyMessage(
        apiMessage,
        response.statusCode,
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw ApiException(
          message: friendlyMessage,
          code: 'AUTH_ERROR',
        );
      }
      if (response.statusCode == 429) {
        throw ApiException(
          message: 'API rate limit exceeded. Please try again later.',
          code: 'RATE_LIMIT',
        );
      }
      if (response.statusCode == 500) {
        throw ApiException(
          message: 'API server error. Please try again later.',
          code: 'SERVER_ERROR',
        );
      }
      throw ApiException(
        message: friendlyMessage,
        code: 'HTTP_ERROR',
      );
    }

    try {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = jsonResponse['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        throw ApiException(
          message: 'Invalid response format from API',
          code: 'PARSE_ERROR',
        );
      }

      final candidate = candidates[0] as Map<String, dynamic>?;
      final content = candidate?['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List<dynamic>?;
      if (parts == null || parts.isEmpty) {
        throw ApiException(
          message: 'Invalid response format from API',
          code: 'PARSE_ERROR',
        );
      }

      for (final element in parts) {
        if (element is Map<String, dynamic>) {
          final text = element['text'] as String?;
          if (text != null && text.isNotEmpty) {
            return text;
          }
        }
      }

      throw ApiException(
        message: 'Invalid response format from API',
        code: 'PARSE_ERROR',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to parse API response: ${e.toString()}',
        code: 'PARSE_ERROR',
      );
    }
  }

  String? _extractApiErrorMessage(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final error = json['error'] as Map<String, dynamic>?;
      final message = error?['message'] as String?;
      if (message != null && message.isNotEmpty) {
        return message;
      }
    } catch (_) {
      // If body is not JSON, return null and fall back to generic message
    }
    return null;
  }

  String _mapApiErrorToFriendlyMessage(String? apiMessage, int statusCode) {
    final raw = apiMessage?.trim() ?? 'API request failed with status code $statusCode';

    final imageErrorPatterns = [
      RegExp(r'Cannot\s+read\s+".*?"\s+\(.*?(?:does not support image input|image input).*?\)', caseSensitive: false),
      RegExp(r'does not support image input', caseSensitive: false),
      RegExp(r'Cannot\s+read', caseSensitive: false),
      RegExp(r'image.*not supported', caseSensitive: false),
      RegExp(r'unsupported.*image', caseSensitive: false),
    ];

    final isImageError = imageErrorPatterns.any((r) => r.hasMatch(raw));

    if (isImageError) {
      return 'The selected AI model does not support image input. Please remove the image and try again, or switch to a model that supports images.';
    }

    if (raw.isEmpty) {
      return 'API request failed with status code $statusCode';
    }

    if (raw.length > 240) {
      return raw.replaceAll(RegExp(r'Invalid JSON payload received\.\s*'), '');
    }

    return raw;
  }
}
