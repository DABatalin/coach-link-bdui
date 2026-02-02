import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/api_exceptions.dart';
import '../../../training/domain/models/assignment.dart';
import '../../../training/domain/training_repository.dart';
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
  const GroupDetailLoaded(this.group, {this.assignments = const []});
  final TrainingGroupDetail group;
  final List<AssignmentListItem> assignments;
}

class GroupDetailError extends GroupDetailState {
  const GroupDetailError(this.message);
  final String message;
}

// Bloc
class GroupDetailBloc extends Bloc<GroupDetailEvent, GroupDetailState> {
  GroupDetailBloc({
    required GroupsRepository repository,
    required TrainingRepository trainingRepository,
  })  : _repository = repository,
        _trainingRepository = trainingRepository,
        super(const GroupDetailInitial()) {
    on<GroupDetailLoadRequested>(_onLoad);
    on<GroupMemberAdded>(_onMemberAdded);
    on<GroupMemberRemoved>(_onMemberRemoved);
  }

  final GroupsRepository _repository;
  final TrainingRepository _trainingRepository;

  Future<void> _onLoad(
    GroupDetailLoadRequested event,
    Emitter<GroupDetailState> emit,
  ) async {
    emit(const GroupDetailLoading());
    try {
      final results = await Future.wait([
        _repository.getGroup(groupId: event.groupId),
        _trainingRepository.getAssignments(groupId: event.groupId, pageSize: 50),
      ]);
      emit(GroupDetailLoaded(
        results[0] as TrainingGroupDetail,
        assignments: (results[1] as dynamic).items as List<AssignmentListItem>,
      ));
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
