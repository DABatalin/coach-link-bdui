// ignore_for_file: implementation_imports
import 'dart:convert';

import 'package:easy_localization/src/localization.dart';
import 'package:easy_localization/src/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> setupLocalization() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final jsonStr =
      await rootBundle.loadString('assets/translations/ru.json');
  final map = jsonDecode(jsonStr) as Map<String, dynamic>;
  Localization.load(const Locale('ru'), translations: Translations(map));
}

extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget widget, {
    List<Override> overrides = const [],
  }) async {
    await pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(home: widget),
      ),
    );
  }

  Future<void> pumpLocalizedApp(
    Widget widget, {
    List<Override> overrides = const [],
  }) async {
    await pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(home: widget),
      ),
    );
    await pumpAndSettle();
  }
}
