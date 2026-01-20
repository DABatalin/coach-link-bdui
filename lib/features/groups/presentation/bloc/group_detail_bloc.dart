import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/api_exceptions.dart';
import '../../domain/groups_repository.dart';
import '../../domain/models/training_group.dart';

// Events
sealed class GroupDetailEvent {
  const GroupDetailEvent();
}

class GroupDetailLoadRequested extends GroupDetailEvent {
  const GroupDetailLoadRequested(this.groupId);
  final String groupId;
}

class GroupMemberAdded extends GroupDetailEvent {
  const GroupMemberAdded({required this.groupId, required this.athleteId});
  final String groupId;
  final String athleteId;
}

class GroupMemberRemoved extends GroupDetailEvent {
  const GroupMemberRemoved({required this.groupId, required this.athleteId});
  final String groupId;
  final String athleteId;
}

// States
sealed class GroupDetailState {
  const GroupDetailState();
}

class GroupDetailInitial extends GroupDetailState {
  const GroupDetailInitial();
}

class GroupDetailLoading extends GroupDetailState {
  const GroupDetailLoading();
}

class GroupDetailLoaded extends GroupDetailState {
  const GroupDetailLoaded(this.group);
  final TrainingGroupDetail group;
}

class GroupDetailError extends GroupDetailState {
  const GroupDetailError(this.message);
  final String message;
}

// Bloc
class GroupDetailBloc extends Bloc<GroupDetailEvent, GroupDetailState> {
  GroupDetailBloc({required GroupsRepository repository})
      : _repository = repository,
        super(const GroupDetailInitial()) {
    on<GroupDetailLoadRequested>(_onLoad);
    on<GroupMemberAdded>(_onMemberAdded);
    on<GroupMemberRemoved>(_onMemberRemoved);
  }

  final GroupsRepository _repository;

  Future<void> _onLoad(
    GroupDetailLoadRequested event,
    Emitter<GroupDetailState> emit,
  ) async {
    emit(const GroupDetailLoading());
    try {
      final group = await _repository.getGroup(groupId: event.groupId);
      emit(GroupDetailLoaded(group));
    } on DioException catch (e) {
      final error = e.error;
      emit(GroupDetailError(
        error is AppException ? error.message : 'Не удалось загрузить группу',
      ));
    } catch (_) {
      emit(const GroupDetailError('Произошла ошибка'));
    }
  }

  Future<void> _onMemberAdded(
    GroupMemberAdded event,
    Emitter<GroupDetailState> emit,
  ) async {
    try {
      await _repository.addMember(
        groupId: event.groupId,
        athleteId: event.athleteId,
      );
      add(GroupDetailLoadRequested(event.groupId));
    } catch (_) {
      // keep current state
    }
  }

  Future<void> _onMemberRemoved(
    GroupMemberRemoved event,
    Emitter<GroupDetailState> emit,
  ) async {
    try {
      await _repository.removeMember(
        groupId: event.groupId,
        athleteId: event.athleteId,
      );
      add(GroupDetailLoadRequested(event.groupId));
    } catch (_) {
      // keep current state
    }
  }
}
