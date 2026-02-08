import 'dart:convert';

import 'package:bdui_kit/bdui_kit.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import 'bdui_data_provider.dart';

/// Реализация BduiDataProvider через Dio + Hive (stale-while-revalidate).
class BduiDataProviderImpl implements BduiDataProvider {
  BduiDataProviderImpl({
    required Dio dio,
    required Box<String> cacheBox,
  })  : _dio = dio,
        _cacheBox = cacheBox;

  final Dio _dio;
  final Box<String> _cacheBox;

  @override
  Future<BduiSchema?> getSchema(String screenId) async {
    // 1. Попробовать из кеша
    final cached = _getCached(screenId);
    if (cached != null) {
      // Фоновое обновление (fire-and-forget)
      _fetchAndCache(screenId);
      return cached;
    }

    // 2. Нет кеша — ждём сервер
    return _fetchAndCache(screenId);
  }

  BduiSchema? _getCached(String screenId) {
    final raw = _cacheBox.get(screenId);
    if (raw == null) return null;

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final schema = BduiSchema.fromJson(json);

      // Проверить TTL
      final savedAt = _cacheBox.get('${screenId}_ts');
      if (savedAt != null) {
        final savedTime = DateTime.parse(savedAt);
        if (DateTime.now().difference(savedTime).inSeconds > schema.ttlSeconds) {
          return null; // Кеш протух
        }
      }

      return schema;
    } catch (e) {
      debugPrint('[BDUI] Cache parse error: $e');
      return null;
    }
  }

  Future<BduiSchema?> _fetchAndCache(String screenId) async {
    try {
      final response = await _dio.get('/api/v1/bdui/screens/$screenId');
      final schema =
          BduiSchema.fromJson(response.data as Map<String, dynamic>);

      // Сохранить в кеш
      await _cacheBox.put(screenId, jsonEncode(schema.toJson()));
      await _cacheBox.put('${screenId}_ts', DateTime.now().toIso8601String());

      return schema;
    } on DioException catch (e) {
      debugPrint('[BDUI] Fetch failed for $screenId: $e');
      return null;
    }
  }
}
