import 'package:flutter/widgets.dart';

import '../models/bdui_action.dart';
import '../models/bdui_component.dart';
import 'built_in_components.dart';

/// Сигнатура builder-функции для BDUI-компонента.
///
/// [component] — описание компонента из JSON-схемы.
/// [children] — уже построенные дочерние виджеты.
/// [onAction] — callback для обработки действий (может быть null).
typedef BduiWidgetBuilder = Widget Function(
  BduiComponent component,
  List<Widget> children,
  void Function(BduiAction action)? onAction,
);

/// Реестр соответствия type → builder.
class ComponentRegistry {
  ComponentRegistry._({required Map<String, BduiWidgetBuilder> builders})
      : _builders = builders;

  final Map<String, BduiWidgetBuilder> _builders;

  /// Реестр со всеми встроенными компонентами.
  factory ComponentRegistry.defaults() {
    final registry = ComponentRegistry._(builders: {});
    registerBuiltInComponents(registry);
    return registry;
  }

  /// Пустой реестр (для тестов или полностью кастомных конфигураций).
  factory ComponentRegistry.empty() {
    return ComponentRegistry._(builders: {});
  }

  /// Зарегистрировать компонент. Перезаписывает существующий builder.
  void register(String type, BduiWidgetBuilder builder) {
    _builders[type] = builder;
  }

  /// Получить builder по типу. Null если не зарегистрирован.
  BduiWidgetBuilder? get(String type) => _builders[type];

  /// Проверить наличие builder для типа.
  bool has(String type) => _builders.containsKey(type);

  /// Все зарегистрированные типы (для отладки).
  Set<String> get registeredTypes => _builders.keys.toSet();
}
