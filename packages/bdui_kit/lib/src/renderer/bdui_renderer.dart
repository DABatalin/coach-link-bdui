import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/bdui_action.dart';
import '../models/bdui_component.dart';
import '../models/bdui_schema.dart';
import '../registry/component_registry.dart';

/// Рекурсивно строит Widget tree из BDUI-схемы.
class BduiRenderer {
  const BduiRenderer({
    required this.registry,
    this.onAction,
  });

  final ComponentRegistry registry;

  /// Callback при взаимодействии с компонентом.
  final void Function(BduiAction action)? onAction;

  /// Построить виджет из полной схемы.
  Widget buildSchema(BduiSchema schema) {
    return buildComponent(schema.root);
  }

  /// Построить виджет из одного компонента (рекурсивно).
  Widget buildComponent(BduiComponent component) {
    final builder = registry.get(component.type);

    if (builder == null) {
      if (kDebugMode) {
        debugPrint('[bdui_kit] Unknown component type: "${component.type}"');
      }
      return const SizedBox.shrink();
    }

    // Рекурсивно построить дочерние виджеты
    final childWidgets =
        component.children.map((child) => buildComponent(child)).toList();

    final widget = builder(component, childWidgets, onAction);

    // Обернуть в KeyedSubtree если есть id (для эффективного обновления)
    if (component.id != null) {
      return KeyedSubtree(
        key: ValueKey(component.id),
        child: widget,
      );
    }

    return widget;
  }
}
