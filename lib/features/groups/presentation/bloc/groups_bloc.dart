import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/api_exceptions.dart';
import '../../domain/groups_repository.dart';
import '../../domain/models/training_group.dart';

// Events
sealed class GroupsEvent {
  const GroupsEvent();
}

class GroupsLoadRequested extends GroupsEvent {
  const GroupsLoadRequested();
}

class GroupCreated extends GroupsEvent {
  const GroupCreated(this.name);
  final String name;
}

class GroupDeleted extends GroupsEvent {
  const GroupDeleted(this.groupId);
  final String groupId;
}

// States
sealed class GroupsState {
  const GroupsState();
}

class GroupsInitial extends GroupsState {
  const GroupsInitial();
}

class GroupsLoading extends GroupsState {
  const GroupsLoading();
}

class GroupsLoaded extends GroupsState {
  const GroupsLoaded(this.groups);
  final List<TrainingGroupSummary> groups;
}

class GroupsError extends GroupsState {
  const GroupsError(this.message);
  final String message;
}

// Bloc
class GroupsBloc extends Bloc<GroupsEvent, GroupsState> {
  GroupsBloc({required GroupsRepository repository})
      : _repository = repository,
        super(const GroupsInitial()) {
    on<GroupsLoadRequested>(_onLoad);
    on<GroupCreated>(_onCreated);
    on<GroupDeleted>(_onDeleted);
  }

  final GroupsRepository _repository;

  Future<void> _onLoad(
    GroupsLoadRequested event,
    Emitter<GroupsState> emit,
  ) async {
    emit(const GroupsLoading());
    try {
      final result = await _repository.getGroups();
      emit(GroupsLoaded(result.items));
    } on DioException catch (e) {
      final error = e.error;
      emit(GroupsError(
        error is AppException ? error.message : 'Не удалось загрузить группы',
      ));
    } catch (_) {
      emit(const GroupsError('Произошла ошибка'));
    }
  }

  Future<void> _onCreated(
    GroupCreated event,
    Emitter<GroupsState> emit,
  ) async {
    try {
      await _repository.createGroup(name: event.name);
      add(const GroupsLoadRequested());
    } catch (_) {
      // keep current state
    }
  }

  Future<void> _onDeleted(
    GroupDeleted event,
    Emitter<GroupsState> emit,
  ) async {
    try {
      await _repository.deleteGroup(groupId: event.groupId);
      add(const GroupsLoadRequested());
    } catch (_) {
      // keep current state
    }
  }
}
