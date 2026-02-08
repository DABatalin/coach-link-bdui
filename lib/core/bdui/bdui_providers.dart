import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../di/api_providers.dart';
import '../di/repository_providers.dart' show useMocks;
import '../navigation/app_router.dart';
import 'bdui_action_handler.dart';
import 'bdui_data_provider.dart';
import 'bdui_data_provider_impl.dart';
import 'bdui_data_provider_mock.dart';

final bduiCacheBoxProvider = Provider<Box<String>>((ref) {
  return Hive.box<String>('bdui_schemas');
});

final bduiDataProviderProvider = Provider<BduiDataProvider>((ref) {
  if (useMocks) return BduiDataProviderMock();
  return BduiDataProviderImpl(
    dio: ref.watch(dioProvider),
    cacheBox: ref.watch(bduiCacheBoxProvider),
  );
});

final bduiActionHandlerProvider = Provider<BduiActionHandler>((ref) {
  return BduiActionHandler(
    router: ref.watch(routerProvider),
    dio: ref.watch(dioProvider),
  );
});
