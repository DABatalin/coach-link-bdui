import 'package:bdui_kit/bdui_kit.dart';

/// Абстрактный интерфейс загрузки BDUI-схем.
/// Возвращает null если схема недоступна (→ нативный fallback).
abstract class BduiDataProvider {
  Future<BduiSchema?> getSchema(String screenId);
}
