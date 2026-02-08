import 'package:equatable/equatable.dart';

/// Действие, привязанное к BDUI-компоненту.
sealed class BduiAction extends Equatable {
  const BduiAction();

  factory BduiAction.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'navigate' => NavigateAction(route: json['route'] as String),
      'api_call' => ApiCallAction(
          method: json['method'] as String? ?? 'GET',
          url: json['url'] as String,
          body: json['body'] as Map<String, dynamic>?,
        ),
      'refresh' => const RefreshAction(),
      _ => UnknownAction(type: type),
    };
  }

  Map<String, dynamic> toJson();
}

/// Навигация по маршруту (GoRouter).
class NavigateAction extends BduiAction {
  const NavigateAction({required this.route});
  final String route;

  @override
  Map<String, dynamic> toJson() => {'type': 'navigate', 'route': route};

  @override
  List<Object?> get props => [route];
}

/// HTTP-запрос к API.
class ApiCallAction extends BduiAction {
  const ApiCallAction({
    required this.method,
    required this.url,
    this.body,
  });

  final String method;
  final String url;
  final Map<String, dynamic>? body;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'api_call',
        'method': method,
        'url': url,
        if (body != null) 'body': body,
      };

  @override
  List<Object?> get props => [method, url, body];
}

/// Обновить текущий BDUI-экран.
class RefreshAction extends BduiAction {
  const RefreshAction();

  @override
  Map<String, dynamic> toJson() => {'type': 'refresh'};

  @override
  List<Object?> get props => [];
}

/// Неизвестное действие — forward-compatibility.
class UnknownAction extends BduiAction {
  const UnknownAction({required this.type});
  final String type;

  @override
  Map<String, dynamic> toJson() => {'type': type};

  @override
  List<Object?> get props => [type];
}
