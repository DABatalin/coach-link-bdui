import 'package:bdui_kit/bdui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

BduiRenderer makeRenderer({void Function(BduiAction)? onAction}) =>
    BduiRenderer(
      registry: ComponentRegistry.defaults(),
      onAction: onAction ?? (_) {},
    );

BduiComponent makeComponent({
  required String type,
  Map<String, dynamic> props = const {},
  List<BduiComponent> children = const [],
  BduiAction? action,
}) =>
    BduiComponent(
      type: type,
      properties: props,
      children: children,
      action: action,
    );

void main() {
  group('BduiRenderer — text component', () {
    testWidgets('renders text content from props', (tester) async {
      final component = makeComponent(
        type: 'text',
        props: {'text': 'Hello World'},
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: makeRenderer().buildComponent(component)),
        ),
      );
      expect(find.text('Hello World'), findsOneWidget);
    });
  });

  group('BduiRenderer — button component', () {
    testWidgets('renders button with label', (tester) async {
      final component = makeComponent(
        type: 'button',
        props: {'text': 'Click Me'},
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: makeRenderer().buildComponent(component)),
        ),
      );
      expect(find.text('Click Me'), findsOneWidget);
    });

    testWidgets('fires NavigateAction when button is tapped', (tester) async {
      BduiAction? captured;
      final component = makeComponent(
        type: 'button',
        props: {'text': 'Go'},
        action: const NavigateAction(route: '/athlete/assignments'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: makeRenderer(onAction: (a) => captured = a)
                .buildComponent(component),
          ),
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.pump();

      expect(captured, isA<NavigateAction>());
      expect((captured as NavigateAction).route, '/athlete/assignments');
    });

    testWidgets('fires RefreshAction when button with refresh is tapped',
        (tester) async {
      BduiAction? captured;
      final component = makeComponent(
        type: 'button',
        props: {'text': 'Refresh'},
        action: const RefreshAction(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: makeRenderer(onAction: (a) => captured = a)
                .buildComponent(component),
          ),
        ),
      );

      await tester.tap(find.text('Refresh'));
      await tester.pump();

      expect(captured, isA<RefreshAction>());
    });
  });

  group('BduiRenderer — spacer component', () {
    testWidgets('renders SizedBox with specified height', (tester) async {
      final component = makeComponent(
        type: 'spacer',
        props: {'height': 24},
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: makeRenderer().buildComponent(component)),
        ),
      );
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.height, 24.0);
    });
  });

  group('BduiRenderer — divider component', () {
    testWidgets('renders a Divider widget', (tester) async {
      final component = makeComponent(type: 'divider');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: makeRenderer().buildComponent(component)),
        ),
      );
      expect(find.byType(Divider), findsOneWidget);
    });
  });

  group('BduiRenderer — unknown component type', () {
    testWidgets('renders SizedBox.shrink for unknown type', (tester) async {
      final component = makeComponent(type: 'unknown_xyz_abc');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: makeRenderer().buildComponent(component)),
        ),
      );
      // Should not throw; renders empty widget
      expect(tester.takeException(), isNull);
    });
  });

  group('BduiRenderer — buildSchema', () {
    testWidgets('renders full schema with nested text', (tester) async {
      final schema = BduiSchema.fromJson({
        'screen_id': 'test',
        'version': '1.0',
        'root': {
          'type': 'scroll_view',
          'props': <String, dynamic>{},
          'children': [
            {
              'type': 'text',
              'props': {'text': 'Dashboard Title'},
              'children': <dynamic>[],
            },
          ],
        },
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: makeRenderer().buildSchema(schema),
          ),
        ),
      );

      expect(find.text('Dashboard Title'), findsOneWidget);
    });
  });
}
