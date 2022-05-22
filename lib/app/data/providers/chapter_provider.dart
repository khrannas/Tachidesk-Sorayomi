import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../core/values/api_url.dart';
import '../chapter_model.dart';
import '../enums/auth_type.dart';
import '../services/local_storage_service.dart';

class ChapterProvider extends GetConnect {
  final LocalStorageService _localStorageService =
      Get.find<LocalStorageService>();
  final CacheManager cacheManager = CacheManager(
      Config("chapter_api", stalePeriod: const Duration(minutes: 15)));
  @override
  void onInit() {
    httpClient.defaultDecoder = (map) {
      if (map is List) {
        return map.map((item) => Chapter.fromMap(item)).toList();
      }
      if (map is Map<String, dynamic>) return Chapter.fromMap(map);
    };
    httpClient.baseUrl = _localStorageService.baseURL + mangaUrl;
    httpClient.timeout = Duration(minutes: 5);
    httpClient.addRequestModifier((Request request) async {
      final token = _localStorageService.basicAuth;
      // Set the header
      if (_localStorageService.baseAuthType == AuthType.basic) {
        request.headers['Authorization'] = token;
      }
      return request;
    });
  }

  Future<List<Chapter>?> getChaptersList(int mangaId,
      {bool onlineFetch = false}) async {
    Response response = await get(
      '/$mangaId/chapters?onlineFetch=$onlineFetch',
    );
    if (response.hasError) return <Chapter>[];
    return response.body;
  }

  Future<Chapter?> getChapter(
      {required int mangaId,
      required int chapterIndex,
      bool useCache = false}) async {
    final url = '/$mangaId/chapter/$chapterIndex';
    if (useCache) {
      // Return from cache first
      final cachedResponse = await cacheManager.getFileFromCache(url);
      if (cachedResponse != null &&
          cachedResponse.validTill.isAfter(DateTime.now())) {
        final json = convertToString(cachedResponse.file.readAsBytesSync());
        return Chapter.fromJson(json);
      }
    }
    final response = await get(
      url,
    );
    // Return null if error
    if (response.hasError) return null;
    if (useCache) {
      // Put response on the cache and return chapter from internet
      cacheManager.putFile(
          url, convertFromString((response.body as Chapter).toJson()));
    }
    return response.body;
  }

  Uint8List convertFromString(String source) {
    var list = List<int>.empty(growable: true);
    for (var rune in source.runes) {
      if (rune >= 0x10000) {
        rune -= 0x10000;
        int firstWord = (rune >> 10) + 0xD800;
        list.add(firstWord >> 8);
        list.add(firstWord & 0xFF);
        int secondWord = (rune & 0x3FF) + 0xDC00;
        list.add(secondWord >> 8);
        list.add(secondWord & 0xFF);
      } else {
        list.add(rune >> 8);
        list.add(rune & 0xFF);
      }
    }
    return Uint8List.fromList(list);
  }

  String convertToString(Uint8List source) {
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < source.length;) {
      int firstWord = (source[i] << 8) + source[i + 1];
      if (0xD800 <= firstWord && firstWord <= 0xDBFF) {
        int secondWord = (source[i + 2] << 8) + source[i + 3];
        buffer.writeCharCode(
            ((firstWord - 0xD800) << 10) + (secondWord - 0xDC00) + 0x10000);
        i += 4;
      } else {
        buffer.writeCharCode(firstWord);
        i += 2;
      }
    }
    return buffer.toString();
  }

  String getChapterPageUrl(
      {required int mangaId, required int chapterIndex, required int page}) {
    return '${httpClient.baseUrl!}/$mangaId/chapter/$chapterIndex/'
        'page/$page?useCache=true';
  }

  Future<Response> patchChapter(
          int mangaId, int chapterIndex, Map<String, dynamic> formdata) async =>
      await patch('/$mangaId/chapter/$chapterIndex', FormData(formdata));

  Future<Response> deletedownloadedChapter({
    required int mangaId,
    required int chapterIndex,
  }) =>
      delete("/$mangaId/chapter/$chapterIndex");
}
