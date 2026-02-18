import 'package:bdui_kit/bdui_kit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BduiComponent', () {
    test('parses type and properties from JSON', () {
      final json = {
        'type': 'text',
        'props': {'text': 'Hello', 'style': 'headline'},
        'children': <dynamic>[],
      };
      final component = BduiComponent.fromJson(json);

      expect(component.type, 'text');
      expect(component.properties['text'], 'Hello');
      expect(component.properties['style'], 'headline');
      expect(component.children, isEmpty);
      expect(component.action, isNull);
    });

    test('parses nested children', () {
      final json = {
        'type': 'column',
        'props': <String, dynamic>{},
        'children': [
          {'type': 'text', 'props': {'text': 'A'}, 'children': <dynamic>[]},
          {'type': 'text', 'props': {'text': 'B'}, 'children': <dynamic>[]},
        ],
      };
      final component = BduiComponent.fromJson(json);

      expect(component.type, 'column');
      expect(component.children.length, 2);
      expect(component.children[0].type, 'text');
      expect(component.children[1].type, 'text');
    });

    test('parses optional id field', () {
      final json = {
        'type': 'card',
        'id': 'main-card',
        'props': <String, dynamic>{},
        'children': <dynamic>[],
      };
      final component = BduiComponent.fromJson(json);
      expect(component.id, 'main-card');
    });

    test('parses NavigateAction from component', () {
      final json = {
        'type': 'button',
        'props': {'label': 'Go'},
        'children': <dynamic>[],
        'action': {'type': 'navigate', 'route': '/coach/athletes'},
      };
      final component = BduiComponent.fromJson(json);

      expect(component.action, isA<NavigateAction>());
      expect((component.action as NavigateAction).route, '/coach/athletes');
    });

    test('parses RefreshAction from component', () {
      final json = {
        'type': 'button',
        'props': {'label': 'Refresh'},
        'children': <dynamic>[],
        'action': {'type': 'refresh'},
      };
      final component = BduiComponent.fromJson(json);
      expect(component.action, isA<RefreshAction>());
    });

    test('parses unknown action as UnknownAction', () {
      final json = {
        'type': 'button',
        'props': <String, dynamic>{},
        'children': <dynamic>[],
        'action': {'type': 'future_action_v2', 'data': '123'},
      };
      final component = BduiComponent.fromJson(json);
      expect(component.action, isA<UnknownAction>());
    });

    test('stringProp returns value or null', () {
      final component = BduiComponent(
        type: 'text',
        properties: {'text': 'Hello'},
        children: [],
      );
      expect(component.stringProp('text'), 'Hello');
      expect(component.stringProp('missing'), isNull);
    });

    test('stringPropOr returns fallback when key missing', () {
      final component = BduiComponent(
        type: 'text',
        properties: {},
        children: [],
      );
      expect(component.stringPropOr('text', 'fallback'), 'fallback');
    });

    test('boolProp returns correct value', () {
      final component = BduiComponent(
        type: 'button',
        properties: {'full_width': true},
        children: [],
      );
      expect(component.boolProp('full_width'), isTrue);
      expect(component.boolProp('missing'), isFalse);
    });

    test('intPropOr returns value or fallback', () {
      final component = BduiComponent(
        type: 'spacer',
        properties: {'height': 16},
        children: [],
      );
      expect(component.intPropOr('height', 0), 16);
      expect(component.intPropOr('width', 8), 8);
    });
  });

  group('BduiSchema', () {
    test('parses from valid JSON', () {
      final json = {
        'screen_id': 'coach-dashboard',
        'version': '1.0.0',
        'ttl_seconds': 300,
        'root': {
          'type': 'scroll_view',
          'props': <String, dynamic>{},
          'children': [
            {
              'type': 'text',
              'props': {'text': 'Hello Coach'},
              'children': <dynamic>[],
            }
          ],
        },
      };

      final schema = BduiSchema.fromJson(json);

      expect(schema.screenId, 'coach-dashboard');
      expect(schema.version, '1.0.0');
      expect(schema.ttlSeconds, 300);
      expect(schema.root.type, 'scroll_view');
      expect(schema.root.children.length, 1);
      expect(schema.root.children[0].type, 'text');
    });

    test('uses default ttlSeconds when not provided', () {
      final json = {
        'screen_id': 'test',
        'version': '1.0',
        'root': {
          'type': 'text',
          'props': {'text': 'Hi'},
          'children': <dynamic>[],
        },
      };
      final schema = BduiSchema.fromJson(json);
      expect(schema.ttlSeconds, isNotNull);
    });
  });

  group('BduiAction', () {
    test('NavigateAction fromJson', () {
      final action = BduiAction.fromJson({'type': 'navigate', 'route': '/home'});
      expect(action, isA<NavigateAction>());
      expect((action as NavigateAction).route, '/home');
    });

    test('RefreshAction fromJson', () {
      final action = BduiAction.fromJson({'type': 'refresh'});
      expect(action, isA<RefreshAction>());
    });

    test('ApiCallAction fromJson', () {
      final action = BduiAction.fromJson({
        'type': 'api_call',
        'method': 'POST',
        'url': '/api/v1/test',
      });
      expect(action, isA<ApiCallAction>());
      expect((action as ApiCallAction).method, 'POST');
      expect(action.url, '/api/v1/test');
    });

    test('UnknownAction fromJson for unrecognised type', () {
      final action = BduiAction.fromJson({'type': 'teleport', 'dest': 'moon'});
      expect(action, isA<UnknownAction>());
    });
  });
}
