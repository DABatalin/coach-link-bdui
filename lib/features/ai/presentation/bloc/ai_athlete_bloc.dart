import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/ai_repository.dart';
import '../../domain/models/ai_result.dart';

// Events
sealed class AiAthleteEvent {
  const AiAthleteEvent();
}

class AiAthleteRecommendationsRequested extends AiAthleteEvent {
  const AiAthleteRecommendationsRequested(this.athleteId);
  final String athleteId;
}

class AiAthleteAnalysisRequested extends AiAthleteEvent {
  const AiAthleteAnalysisRequested(this.athleteId);
  final String athleteId;
}

// States
sealed class AiAthleteState {
  const AiAthleteState();
}

class AiAthleteInitial extends AiAthleteState {
  const AiAthleteInitial();
}

class AiAthleteLoading extends AiAthleteState {
  const AiAthleteLoading();
}

class AiAthleteLoaded extends AiAthleteState {
  const AiAthleteLoaded(this.result);
  final AiResult result;
}

class AiAthleteError extends AiAthleteState {
  const AiAthleteError(this.message);
  final String message;
}

// Bloc
class AiAthleteBloc extends Bloc<AiAthleteEvent, AiAthleteState> {
  AiAthleteBloc({required AiRepository repository})
      : _repository = repository,
        super(const AiAthleteInitial()) {
    on<AiAthleteRecommendationsRequested>(_onRecommendations);
    on<AiAthleteAnalysisRequested>(_onAnalysis);
  }

  final AiRepository _repository;

  Future<void> _onRecommendations(
    AiAthleteRecommendationsRequested event,
    Emitter<AiAthleteState> emit,
  ) async {
    emit(const AiAthleteLoading());
    try {
      final result = await _repository.getAthleteRecommendations(
        athleteId: event.athleteId,
      );
      emit(AiAthleteLoaded(result));
    } on DioException catch (e) {
      emit(AiAthleteError(_extractError(e, 'Не удалось получить рекомендации от ИИ')));
    } catch (_) {
      emit(const AiAthleteError('Не удалось получить рекомендации от ИИ'));
    }
  }

  Future<void> _onAnalysis(
    AiAthleteAnalysisRequested event,
    Emitter<AiAthleteState> emit,
  ) async {
    emit(const AiAthleteLoading());
    try {
      final result = await _repository.getAthleteAnalysis(
        athleteId: event.athleteId,
      );
      emit(AiAthleteLoaded(result));
    } on DioException catch (e) {
      emit(AiAthleteError(_extractError(e, 'Не удалось получить анализ от ИИ')));
    } catch (_) {
      emit(const AiAthleteError('Не удалось получить анализ от ИИ'));
    }
  }

  String _extractError(DioException e, String fallback) {
    try {
      final data = e.response?.data;
      if (data is Map) {
        final error = data['error'];
        if (error is Map && error['message'] is String) {
          return error['message'] as String;
        }
      }
    } catch (_) {}
    return fallback;
  }
}
