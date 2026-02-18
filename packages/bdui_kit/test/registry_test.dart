import 'package:bdui_kit/bdui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ComponentRegistry', () {
    test('defaults() contains all built-in component types', () {
      final registry = ComponentRegistry.defaults();

      const expectedTypes = [
        'text',
        'card',
        'list',
        'list_tile',
        'scroll_view',
        'button',
        'image',
        'spacer',
        'divider',
        'row',
        'container',
        'icon',
        'badge',
      ];

      for (final type in expectedTypes) {
        expect(
          registry.has(type),
          isTrue,
          reason: 'Registry should contain "$type"',
        );
      }
    });

    test('empty() contains no built-in components', () {
      final registry = ComponentRegistry.empty();
      expect(registry.has('text'), isFalse);
      expect(registry.has('button'), isFalse);
    });

    test('register() adds a custom component type', () {
      final registry = ComponentRegistry.empty();

      registry.register(
        'custom_widget',
        (component, children, onAction) => const Text('Custom'),
      );

      expect(registry.has('custom_widget'), isTrue);
    });

    test('register() overrides an existing component', () {
      final registry = ComponentRegistry.defaults();

      registry.register(
        'text',
        (component, children, onAction) => const Text('Overridden'),
      );

      final builder = registry.get('text');
      expect(builder, isNotNull);
    });

    test('get() returns null for unknown type', () {
      final registry = ComponentRegistry.empty();
      expect(registry.get('unknown_xyz'), isNull);
    });

    test('registeredTypes includes all registered types', () {
      final registry = ComponentRegistry.empty();
      registry.register('a', (c, ch, o) => const SizedBox());
      registry.register('b', (c, ch, o) => const SizedBox());

      expect(registry.registeredTypes, containsAll(['a', 'b']));
    });
  });
}
