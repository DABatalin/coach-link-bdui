import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/api_exceptions.dart';
import '../../../../core/auth/auth_manager.dart';
import '../../../auth/domain/models/user.dart';
import '../../domain/profile_repository.dart';

// Events
sealed class ProfileEvent {
  const ProfileEvent();
}

class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

class ProfileLogoutRequested extends ProfileEvent {
  const ProfileLogoutRequested();
}

// States
sealed class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  const ProfileLoaded(this.user);
  final User user;
}

class ProfileError extends ProfileState {
  const ProfileError(this.message);
  final String message;
}

// Bloc
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required ProfileRepository repository,
    required AuthManager authManager,
  })  : _repository = repository,
        _authManager = authManager,
        super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoad);
    on<ProfileLogoutRequested>(_onLogout);
  }

  final ProfileRepository _repository;
  final AuthManager _authManager;

  Future<void> _onLoad(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final user = await _repository.getMyProfile();
      emit(ProfileLoaded(user));
    } on DioException catch (e) {
      final error = e.error;
      if (error is AppException) {
        emit(ProfileError(error.message));
      } else {
        emit(const ProfileError('Не удалось загрузить профиль'));
      }
    } catch (_) {
      emit(const ProfileError('Произошла ошибка'));
    }
  }

  Future<void> _onLogout(
    ProfileLogoutRequested event,
    Emitter<ProfileState> emit,
  ) async {
    await _authManager.logout();
  }
}
