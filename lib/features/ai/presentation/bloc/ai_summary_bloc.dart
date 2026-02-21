import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/ai_repository.dart';
import '../../domain/models/ai_result.dart';

// Events
sealed class AiSummaryEvent {
  const AiSummaryEvent();
}

class AiSummaryRequested extends AiSummaryEvent {
  const AiSummaryRequested({this.dateFrom, this.dateTo});
  final DateTime? dateFrom;
  final DateTime? dateTo;
}

// States
sealed class AiSummaryState {
  const AiSummaryState();
}

class AiSummaryInitial extends AiSummaryState {
  const AiSummaryInitial();
}

class AiSummaryLoading extends AiSummaryState {
  const AiSummaryLoading();
}

class AiSummaryLoaded extends AiSummaryState {
  const AiSummaryLoaded(this.result);
  final AiResult result;
}

class AiSummaryError extends AiSummaryState {
  const AiSummaryError(this.message);
  final String message;
}

// Bloc
class AiSummaryBloc extends Bloc<AiSummaryEvent, AiSummaryState> {
  AiSummaryBloc({required AiRepository repository})
      : _repository = repository,
        super(const AiSummaryInitial()) {
    on<AiSummaryRequested>(_onRequested);
  }

  final AiRepository _repository;

  Future<void> _onRequested(
    AiSummaryRequested event,
    Emitter<AiSummaryState> emit,
  ) async {
    emit(const AiSummaryLoading());
    try {
      final result = await _repository.getCoachSummary(
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
      );
      emit(AiSummaryLoaded(result));
    } on DioException catch (e) {
      final msg = _extractError(e) ?? 'Не удалось получить сводку от ИИ';
      emit(AiSummaryError(msg));
    } catch (_) {
      emit(const AiSummaryError('Не удалось получить сводку от ИИ'));
    }
  }

  String? _extractError(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map) {
        final error = data['error'];
        if (error is Map && error['message'] is String) {
          return error['message'] as String;
        }
      }
    } catch (_) {}
    return null;
  }
}
