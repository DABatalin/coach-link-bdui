import 'dart:async';
import 'dart:io';

import 'package:alchemist/alchemist.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final isCI = Platform.environment.containsKey('CI');

  return AlchemistConfig.runWithConfig(
    config: AlchemistConfig(
      // На CI запускаем только ci-variant; платформенные (linux/) не нужны
      platformGoldensConfig: PlatformGoldensConfig(enabled: !isCI),
    ),
    run: testMain,
  );
}
