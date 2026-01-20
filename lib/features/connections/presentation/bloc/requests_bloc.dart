import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/api_exceptions.dart';
import '../../domain/connections_repository.dart';
import '../../domain/models/connection_request.dart';

// Events
sealed class RequestsEvent {
  const RequestsEvent();
}

class RequestsLoadRequested extends RequestsEvent {
  const RequestsLoadRequested();
}

class RequestAccepted extends RequestsEvent {
  const RequestAccepted(this.requestId);
  final String requestId;
}

class RequestRejected extends RequestsEvent {
  const RequestRejected(this.requestId);
  final String requestId;
}

// States
sealed class RequestsState {
  const RequestsState();
}

class RequestsInitial extends RequestsState {
  const RequestsInitial();
}

class RequestsLoading extends RequestsState {
  const RequestsLoading();
}

class RequestsLoaded extends RequestsState {
  const RequestsLoaded(this.requests);
  final List<ConnectionRequest> requests;
}

class RequestsError extends RequestsState {
  const RequestsError(this.message);
  final String message;
}

// Bloc
class RequestsBloc extends Bloc<RequestsEvent, RequestsState> {
  RequestsBloc({required ConnectionsRepository repository})
      : _repository = repository,
        super(const RequestsInitial()) {
    on<RequestsLoadRequested>(_onLoad);
    on<RequestAccepted>(_onAccepted);
    on<RequestRejected>(_onRejected);
  }

  final ConnectionsRepository _repository;

  Future<void> _onLoad(
    RequestsLoadRequested event,
    Emitter<RequestsState> emit,
  ) async {
    emit(const RequestsLoading());
    try {
      final result = await _repository.getIncomingRequests();
      emit(RequestsLoaded(result.items));
    } on DioException catch (e) {
      final error = e.error;
      emit(RequestsError(
        error is AppException ? error.message : 'Не удалось загрузить заявки',
      ));
    } catch (_) {
      emit(const RequestsError('Произошла ошибка'));
    }
  }

  Future<void> _onAccepted(
    RequestAccepted event,
    Emitter<RequestsState> emit,
  ) async {
    try {
      await _repository.acceptRequest(requestId: event.requestId);
      add(const RequestsLoadRequested());
    } catch (_) {
      // keep current state, show snackbar from UI
    }
  }

  Future<void> _onRejected(
    RequestRejected event,
    Emitter<RequestsState> emit,
  ) async {
    try {
      await _repository.rejectRequest(requestId: event.requestId);
      add(const RequestsLoadRequested());
    } catch (_) {
      // keep current state
    }
  }
}
