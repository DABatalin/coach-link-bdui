import 'package:equatable/equatable.dart';

import 'bdui_action.dart';

/// Узел дерева BDUI-компонентов.
class BduiComponent extends Equatable {
  const BduiComponent({
    required this.type,
    this.id,
    this.properties = const {},
    this.children = const [],
    this.action,
  });

  /// Тип компонента (ключ в ComponentRegistry).
  final String type;

  /// Уникальный идентификатор (для тестов и ValueKey).
  final String? id;

  /// Свойства, специфичные для типа.
  final Map<String, dynamic> properties;

  /// Дочерние компоненты.
  final List<BduiComponent> children;

  /// Действие при взаимодействии.
  final BduiAction? action;

  // ---------------------------------------------------------------------------
  // Типизированные хелперы для доступа к properties
  // ---------------------------------------------------------------------------

  String? stringProp(String key) => properties[key] as String?;
  String stringPropOr(String key, String fallback) =>
      stringProp(key) ?? fallback;

  int? intProp(String key) => properties[key] as int?;
  int intPropOr(String key, int fallback) => intProp(key) ?? fallback;

  double? doubleProp(String key) => (properties[key] as num?)?.toDouble();
  double doublePropOr(String key, double fallback) =>
      doubleProp(key) ?? fallback;

  bool boolProp(String key, {bool fallback = false}) =>
      (properties[key] as bool?) ?? fallback;

  // ---------------------------------------------------------------------------
  // Serialization
  // ---------------------------------------------------------------------------

  factory BduiComponent.fromJson(Map<String, dynamic> json) {
    return BduiComponent(
      type: json['type'] as String,
      id: json['id'] as String?,
      properties: (json['props'] as Map<String, dynamic>?) ?? const {},
      children: (json['children'] as List<dynamic>?)
              ?.map((c) => BduiComponent.fromJson(c as Map<String, dynamic>))
              .toList() ??
          const [],
      action: json['action'] != null
          ? BduiAction.fromJson(json['action'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        if (id != null) 'id': id,
        if (properties.isNotEmpty) 'props': properties,
        if (children.isNotEmpty)
          'children': children.map((c) => c.toJson()).toList(),
        if (action != null) 'action': action!.toJson(),
      };

  @override
  List<Object?> get props => [type, id, properties, children, action];
}
