import 'package:flutter_bloc/flutter_bloc.dart';

import 'analytics_service.dart';

class AnalyticsBlocObserver extends BlocObserver {
  AnalyticsBlocObserver(this._service);

  final AnalyticsService _service;

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    _service.recordError(error, stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}
