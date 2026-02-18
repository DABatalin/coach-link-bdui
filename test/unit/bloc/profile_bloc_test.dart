import 'package:bloc_test/bloc_test.dart';
import 'package:coach_link/core/api/api_exceptions.dart';
import 'package:coach_link/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_repositories.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockProfileRepository profileRepo;
  late MockAuthManager authManager;

  setUp(() {
    profileRepo = MockProfileRepository();
    authManager = MockAuthManager();
  });

  ProfileBloc buildBloc() => ProfileBloc(
        repository: profileRepo,
        authManager: authManager,
      );

  group('ProfileBloc', () {
    test('initial state is ProfileInitial', () {
      expect(buildBloc().state, isA<ProfileInitial>());
    });

    blocTest<ProfileBloc, ProfileState>(
      'emits [Loading, Loaded] when profile loads successfully',
      build: () {
        when(() => profileRepo.getMyProfile())
            .thenAnswer((_) async => makeUser(fullName: 'Ivan Petrov'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ProfileLoadRequested()),
      expect: () => [
        isA<ProfileLoading>(),
        isA<ProfileLoaded>()
            .having((s) => s.user.fullName, 'fullName', 'Ivan Petrov'),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [Loading, Error] on DioException',
      build: () {
        when(() => profileRepo.getMyProfile()).thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
          error: const ForbiddenException(),
        ));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ProfileLoadRequested()),
      expect: () => [
        isA<ProfileLoading>(),
        isA<ProfileError>(),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [Loading, Error] on generic exception',
      build: () {
        when(() => profileRepo.getMyProfile())
            .thenThrow(Exception('No connection'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ProfileLoadRequested()),
      expect: () => [isA<ProfileLoading>(), isA<ProfileError>()],
    );

    blocTest<ProfileBloc, ProfileState>(
      'calls authManager.logout on ProfileLogoutRequested',
      build: () {
        when(() => authManager.logout()).thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ProfileLogoutRequested()),
      verify: (_) => verify(() => authManager.logout()).called(1),
    );
  });
}
