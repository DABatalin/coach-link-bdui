import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/api_exceptions.dart';
import '../../../auth/domain/models/user.dart';
import '../../domain/connections_repository.dart';

// Events
sealed class FindCoachEvent {
  const FindCoachEvent();
}

class FindCoachQueryChanged extends FindCoachEvent {
  const FindCoachQueryChanged(this.query);
  final String query;
}

class FindCoachRequestSent extends FindCoachEvent {
  const FindCoachRequestSent(this.coachId);
  final String coachId;
}

// States
class FindCoachState {
  const FindCoachState({
    this.query = '',
    this.results = const [],
    this.isSearching = false,
    this.isSending = false,
    this.sentCoachId,
    this.errorMessage,
    this.successMessage,
  });

  final String query;
  final List<User> results;
  final bool isSearching;
  final bool isSending;
  final String? sentCoachId;
  final String? errorMessage;
  final String? successMessage;

  FindCoachState copyWith({
    String? query,
    List<User>? results,
    bool? isSearching,
    bool? isSending,
    String? sentCoachId,
    String? errorMessage,
    String? successMessage,
  }) {
    return FindCoachState(
      query: query ?? this.query,
      results: results ?? this.results,
      isSearching: isSearching ?? this.isSearching,
      isSending: isSending ?? this.isSending,
      sentCoachId: sentCoachId ?? this.sentCoachId,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

// Bloc
class FindCoachBloc extends Bloc<FindCoachEvent, FindCoachState> {
  FindCoachBloc({required ConnectionsRepository repository})
      : _repository = repository,
        super(const FindCoachState()) {
    on<FindCoachQueryChanged>(_onQueryChanged);
    on<FindCoachRequestSent>(_onRequestSent);
  }

  final ConnectionsRepository _repository;

  Future<void> _onQueryChanged(
    FindCoachQueryChanged event,
    Emitter<FindCoachState> emit,
  ) async {
    final query = event.query.trim();
    if (query.length < 2) {
      emit(state.copyWith(query: query, results: [], isSearching: false));
      return;
    }

    emit(state.copyWith(query: query, isSearching: true));
    try {
      final result = await _repository.searchUsers(
        query: query,
        role: 'coach',
      );
      emit(state.copyWith(results: result.items, isSearching: false));
    } catch (_) {
      emit(state.copyWith(isSearching: false));
    }
  }

  Future<void> _onRequestSent(
    FindCoachRequestSent event,
    Emitter<FindCoachState> emit,
  ) async {
    emit(state.copyWith(isSending: true));
    try {
      await _repository.sendConnectionRequest(coachId: event.coachId);
      emit(state.copyWith(
        isSending: false,
        sentCoachId: event.coachId,
        successMessage: 'Заявка отправлена',
      ));
    } on DioException catch (e) {
      final error = e.error;
      emit(state.copyWith(
        isSending: false,
        errorMessage:
            error is AppException ? error.message : 'Не удалось отправить заявку',
      ));
    } catch (_) {
      emit(state.copyWith(
        isSending: false,
        errorMessage: 'Произошла ошибка',
      ));
    }
  }
}
