import 'package:equatable/equatable.dart';

import 'bdui_component.dart';

/// Корневая модель BDUI-схемы.
class BduiSchema extends Equatable {
  const BduiSchema({
    required this.screenId,
    required this.version,
    required this.root,
    this.ttlSeconds = 3600,
  });

  /// Идентификатор экрана (например, 'coach-dashboard').
  final String screenId;

  /// Семантическая версия схемы (для кеш-инвалидации).
  final String version;

  /// Время жизни кеша в секундах.
  final int ttlSeconds;

  /// Корневой компонент дерева.
  final BduiComponent root;

  factory BduiSchema.fromJson(Map<String, dynamic> json) {
    return BduiSchema(
      screenId: json['screen_id'] as String,
      version: json['version'] as String,
      ttlSeconds: json['ttl_seconds'] as int? ?? 3600,
      root: BduiComponent.fromJson(json['root'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'screen_id': screenId,
        'version': version,
        'ttl_seconds': ttlSeconds,
        'root': root.toJson(),
      };

  @override
  List<Object?> get props => [screenId, version, ttlSeconds, root];
}
