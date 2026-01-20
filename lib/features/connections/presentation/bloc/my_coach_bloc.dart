import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/api_exceptions.dart';
import '../../domain/connections_repository.dart';
import '../../domain/models/coach_info.dart';
import '../../domain/models/connection_request.dart';

// Events
sealed class MyCoachEvent {
  const MyCoachEvent();
}

class MyCoachLoadRequested extends MyCoachEvent {
  const MyCoachLoadRequested();
}

// States
sealed class MyCoachState {
  const MyCoachState();
}

class MyCoachInitial extends MyCoachState {
  const MyCoachInitial();
}

class MyCoachLoading extends MyCoachState {
  const MyCoachLoading();
}

class MyCoachConnected extends MyCoachState {
  const MyCoachConnected(this.coach);
  final CoachInfo coach;
}

class MyCoachPending extends MyCoachState {
  const MyCoachPending(this.request);
  final ConnectionRequest request;
}

class MyCoachNone extends MyCoachState {
  const MyCoachNone();
}

class MyCoachError extends MyCoachState {
  const MyCoachError(this.message);
  final String message;
}

// Bloc
class MyCoachBloc extends Bloc<MyCoachEvent, MyCoachState> {
  MyCoachBloc({required ConnectionsRepository repository})
      : _repository = repository,
        super(const MyCoachInitial()) {
    on<MyCoachLoadRequested>(_onLoad);
  }

  final ConnectionsRepository _repository;

  Future<void> _onLoad(
    MyCoachLoadRequested event,
    Emitter<MyCoachState> emit,
  ) async {
    emit(const MyCoachLoading());
    try {
      final coach = await _repository.getAthleteCoach();
      emit(MyCoachConnected(coach));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // No coach — check for pending request
        try {
          final request = await _repository.getOutgoingRequest();
          if (request != null) {
            emit(MyCoachPending(request));
          } else {
            emit(const MyCoachNone());
          }
        } catch (_) {
          emit(const MyCoachNone());
        }
        return;
      }
      final error = e.error;
      emit(MyCoachError(
        error is AppException ? error.message : 'Не удалось загрузить данные',
      ));
    } catch (_) {
      emit(const MyCoachError('Произошла ошибка'));
    }
  }
}
