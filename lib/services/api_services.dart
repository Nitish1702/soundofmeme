import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../utils/utils.dart';

const DEFAULT_MODEL = "chirp-v3-5";

class AudioInfo {
  String id;
  String? title;
  String? imageUrl;
  String? lyric;
  String? audioUrl;
  String? videoUrl;
  String createdAt;
  String modelName;
  String? gptDescriptionPrompt;
  String? prompt;
  String status;
  String? type;
  String? tags;
  String? duration;
  String? errorMessage;

  AudioInfo({
    required this.id,
    this.title,
    this.imageUrl,
    this.lyric,
    this.audioUrl,
    this.videoUrl,
    required this.createdAt,
    required this.modelName,
    this.gptDescriptionPrompt,
    this.prompt,
    required this.status,
    this.type,
    this.tags,
    this.duration,
    this.errorMessage,
  });

  factory AudioInfo.fromJson(Map<String, dynamic> json) {
    return AudioInfo(
      id: json['id'] ?? '',
      title: json['title'] as String?,
      imageUrl: json['image_url'] as String?,
      lyric: json['lyric'] as String?,
      audioUrl: json['audio_url'] as String?,
      videoUrl: json['video_url'] as String?,
      createdAt: json['created_at'] ?? '',
      modelName: json['model_name'] ?? '',
      gptDescriptionPrompt: json['gpt_description_prompt'] as String?,
      prompt: json['prompt'] as String?,
      status: json['status'] ?? '',
      type: json['type'] as String?,
      tags: json['tags'] as String?,
      duration: json['duration'] as String?,
      errorMessage: json['error_message'] as String?,
    );
  }
}

class SunoApi {
  static const String BASE_URL = 'https://studio-api.suno.ai';
  static const String CLERK_BASE_URL = 'https://clerk.suno.com';

  final http.Client _client;
  String? _sid;
  String? _currentToken;
  String _cookie;

  SunoApi(String cookie)
      : _client = http.Client(),
        _cookie = cookie;

  Future<SunoApi> init() async {
    await _getAuthToken();
    await keepAlive();
    return this;
  }

  Future<void> _getAuthToken() async {
    final response = await _client.get(
      Uri.parse('$CLERK_BASE_URL/v1/client?_clerk_js_version=4.73.3'),
      headers: {
        HttpHeaders.userAgentHeader: 'User-Agent',
        HttpHeaders.cookieHeader: _cookie,
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );
    final responseData = jsonDecode(response.body);
    if (responseData['response']['last_active_session_id'] == null) {
      throw Exception('Failed to get session id, you may need to update the SUNO_COOKIE');
    }
    _sid = responseData['response']['last_active_session_id'];
  }

  Future<void> keepAlive([bool isWait = false]) async {
    if (_sid == null) {
      throw Exception('Session ID is not set. Cannot renew token.');
    }
    final response = await _client.post(
      Uri.parse('$CLERK_BASE_URL/v1/client/sessions/$_sid/tokens?_clerk_js_version=4.73.3'),
      headers: {
        HttpHeaders.userAgentHeader: 'User-Agent',
        HttpHeaders.cookieHeader: _cookie,
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );
    final responseData = jsonDecode(response.body);
    if (isWait) {
      await sleep(1, 2);
    }
    _currentToken = responseData['jwt'];
  }

  Future<List<AudioInfo>> generate(
      String prompt, {
        bool makeInstrumental = false,
        String? model,
        bool waitAudio = true,
      }) async {
    await keepAlive(false);
    final startTime = DateTime.now();
    final audios = await _generateSongs(prompt, false, null, null, makeInstrumental, model, waitAudio);
    final costTime = DateTime.now().difference(startTime).inMilliseconds;
    print('Generate Response:\n${jsonEncode(audios)}');
    print('Cost time: $costTime');
    return audios;
  }

  Future<AudioInfo> concatenate(String clipId) async {
    await keepAlive(false);
    final response = await _client.post(
      Uri.parse('$BASE_URL/api/generate/concat/v2/'),
      headers: {
        HttpHeaders.userAgentHeader: 'User-Agent',
        HttpHeaders.cookieHeader: _cookie,
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $_currentToken',
      },
      body: jsonEncode({'clip_id': clipId}),
    );
    if (response.statusCode != 200) {
      throw Exception('Error response: ${response.reasonPhrase}');
    }
    return AudioInfo.fromJson(jsonDecode(response.body));
  }

  Future<List<AudioInfo>> customGenerate(
      String prompt,
      String tags,
      String title, {
        bool makeInstrumental = false,
        String? model,
        bool waitAudio = false,
      }) async {
    final startTime = DateTime.now();
    final audios = await _generateSongs(prompt, true, tags, title, makeInstrumental, model, waitAudio);
    final costTime = DateTime.now().difference(startTime).inMilliseconds;
    print('Custom Generate Response:\n${jsonEncode(audios)}');
    print('Cost time: $costTime');
    return audios;
  }

  Future<List<AudioInfo>> _generateSongs(
      String prompt,
      bool isCustom,
      String? tags,
      String? title,
      bool? makeInstrumental,
      String? model,
      bool waitAudio,
      ) async {
    await keepAlive(false);
    final payload = {
      'make_instrumental': makeInstrumental ?? false,
      'mv': model ?? DEFAULT_MODEL,
      'prompt': '',
    };
    if (isCustom) {
      payload['tags'] = tags ?? '';  // Use empty string if null
      payload['title'] = title ?? '';  // Use empty string if null
      payload['prompt'] = prompt;
    } else {
      payload['gpt_description_prompt'] = prompt;
    }

    print('generateSongs payload:\n${jsonEncode(payload)}');
    final response = await _client.post(
      Uri.parse('$BASE_URL/api/generate/v2/'),
      headers: {
        HttpHeaders.userAgentHeader: 'User-Agent',
        HttpHeaders.cookieHeader: _cookie,
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $_currentToken',
      },
      body: jsonEncode(payload),
    );
    print('generateSongs Response:\n${jsonEncode(jsonDecode(response.body))}');
    if (response.statusCode != 200) {
      throw Exception('Error response: ${response.reasonPhrase}');
    }
    final songIds = (jsonDecode(response.body)['clips'] as List).map((audio) => audio['id'] as String).toList();
    if (waitAudio) {
      final startTime = DateTime.now();
      List<AudioInfo> lastResponse = [];
      await sleep(5, 5);
      while (DateTime.now().difference(startTime).inMilliseconds < 100000) {
        final statusResponse = await get(songIds);
        final allCompleted = statusResponse.every((audio) => audio.status == 'streaming' || audio.status == 'complete');
        final allError = statusResponse.every((audio) => audio.status == 'error');
        if (allCompleted || allError) {
          return statusResponse;
        }
        lastResponse = statusResponse;
        await sleep(3, 6);
        await keepAlive(true);
      }
      return lastResponse;
    } else {
      await keepAlive(true);
      return (jsonDecode(response.body)['clips'] as List).map((audio) => AudioInfo.fromJson(audio)).toList();
    }
  }

  Future<String> generateLyrics(String prompt) async {
    await keepAlive(false);
    final generateResponse = await _client.post(
      Uri.parse('$BASE_URL/api/generate/lyrics/'),
      headers: {
        HttpHeaders.userAgentHeader: 'User-Agent',
        HttpHeaders.cookieHeader: _cookie,
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $_currentToken',
      },
      body: jsonEncode({'prompt': prompt}),
    );
    final generateId = jsonDecode(generateResponse.body)['id'];
    var lyricsResponse = await _client.get(
      Uri.parse('$BASE_URL/api/generate/lyrics/$generateId'),
      headers: {
        HttpHeaders.userAgentHeader: 'User-Agent',
        HttpHeaders.cookieHeader: _cookie,
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $_currentToken',
      },
    );
    while (jsonDecode(lyricsResponse.body)['status'] != 'complete') {
      await sleep(2);
      lyricsResponse = await _client.get(
        Uri.parse('$BASE_URL/api/generate/lyrics/$generateId'),
        headers: {
          HttpHeaders.userAgentHeader: 'User-Agent',
          HttpHeaders.cookieHeader: _cookie,
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_currentToken',
        },
      );
    }
    return jsonDecode(lyricsResponse.body)['lyrics'];
  }

  Future<List<AudioInfo>> get(List<String> ids) async {
    await keepAlive(false);
    final payload = {
      'ids': ids,
    };
    final response = await _client.post(
      Uri.parse('$BASE_URL/api/get/'),
      headers: {
        HttpHeaders.userAgentHeader: 'User-Agent',
        HttpHeaders.cookieHeader: _cookie,
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $_currentToken',
      },
      body: jsonEncode(payload),
    );
    if (response.statusCode != 200) {
      throw Exception('Error response: ${response.reasonPhrase}');
    }
    return (jsonDecode(response.body)['audios'] as List).map((audio) => AudioInfo.fromJson(audio)).toList();
  }
}
