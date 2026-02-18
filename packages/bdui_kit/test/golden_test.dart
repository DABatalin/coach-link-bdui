import 'dart:convert';
import 'dart:io';

import 'package:alchemist/alchemist.dart';
import 'package:bdui_kit/bdui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BDUI Golden Tests', () {
    final renderer = BduiRenderer(
      registry: ComponentRegistry.defaults(),
      onAction: (_) {},
    );

    goldenTest(
      'coach_dashboard matches golden',
      fileName: 'coach_dashboard',
      builder: () => GoldenTestScenario(
        name: 'Coach Dashboard',
        child: Material(
          child: SizedBox(
            width: 400,
            child: renderer.buildSchema(
              BduiSchema.fromJson(_loadFixtureSync('coach_dashboard.json')),
            ),
          ),
        ),
      ),
    );

    goldenTest(
      'athlete_dashboard matches golden',
      fileName: 'athlete_dashboard',
      builder: () => GoldenTestScenario(
        name: 'Athlete Dashboard',
        child: Material(
          child: SizedBox(
            width: 400,
            child: renderer.buildSchema(
              BduiSchema.fromJson(_loadFixtureSync('athlete_dashboard.json')),
            ),
          ),
        ),
      ),
    );

    goldenTest(
      'training_detail matches golden',
      fileName: 'training_detail',
      builder: () => GoldenTestScenario(
        name: 'Training Detail',
        child: Material(
          child: SizedBox(
            width: 400,
            child: renderer.buildSchema(
              BduiSchema.fromJson(_loadFixtureSync('training_detail.json')),
            ),
          ),
        ),
      ),
    );

    goldenTest(
      'empty_states matches golden',
      fileName: 'empty_states',
      builder: () => GoldenTestScenario(
        name: 'Empty States',
        child: Material(
          child: SizedBox(
            width: 400,
            child: renderer.buildSchema(
              BduiSchema.fromJson(_loadFixtureSync('empty_states.json')),
            ),
          ),
        ),
      ),
    );

    goldenTest(
      'text_components matches golden',
      fileName: 'text_components',
      builder: () => GoldenTestScenario(
        name: 'Text Components',
        child: Material(
          child: SizedBox(
            width: 400,
            child: renderer.buildSchema(
              BduiSchema.fromJson(_loadFixtureSync('text_components.json')),
            ),
          ),
        ),
      ),
    );

    goldenTest(
      'button_components matches golden',
      fileName: 'button_components',
      builder: () => GoldenTestScenario(
        name: 'Button Components',
        child: Material(
          child: SizedBox(
            width: 400,
            child: renderer.buildSchema(
              BduiSchema.fromJson(_loadFixtureSync('button_components.json')),
            ),
          ),
        ),
      ),
    );

    goldenTest(
      'card_components matches golden',
      fileName: 'card_components',
      builder: () => GoldenTestScenario(
        name: 'Card Components',
        child: Material(
          child: SizedBox(
            width: 400,
            child: renderer.buildSchema(
              BduiSchema.fromJson(_loadFixtureSync('card_components.json')),
            ),
          ),
        ),
      ),
    );

    goldenTest(
      'list_components matches golden',
      fileName: 'list_components',
      builder: () => GoldenTestScenario(
        name: 'List Components',
        child: Material(
          child: SizedBox(
            width: 400,
            child: renderer.buildSchema(
              BduiSchema.fromJson(_loadFixtureSync('list_components.json')),
            ),
          ),
        ),
      ),
    );

    goldenTest(
      'layout_components matches golden',
      fileName: 'layout_components',
      builder: () => GoldenTestScenario(
        name: 'Layout Components',
        child: Material(
          child: SizedBox(
            width: 400,
            child: renderer.buildSchema(
              BduiSchema.fromJson(_loadFixtureSync('layout_components.json')),
            ),
          ),
        ),
      ),
    );
  });
}

Map<String, dynamic> _loadFixtureSync(String name) {
  final file = File('test/fixtures/$name');
  final content = file.readAsStringSync();
  return jsonDecode(content) as Map<String, dynamic>;
}
