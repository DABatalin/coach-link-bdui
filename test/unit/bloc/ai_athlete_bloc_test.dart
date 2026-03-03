import 'package:bloc_test/bloc_test.dart';
import 'package:coach_link/features/ai/presentation/bloc/ai_athlete_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_repositories.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockAiRepository aiRepo;

  setUp(() {
    aiRepo = MockAiRepository();
  });

  AiAthleteBloc buildBloc() => AiAthleteBloc(repository: aiRepo);

  group('AiAthleteBloc', () {
    test('initial state is AiAthleteInitial', () {
      expect(buildBloc().state, isA<AiAthleteInitial>());
    });

    blocTest<AiAthleteBloc, AiAthleteState>(
      'emits [Loading, Loaded] on AiAthleteRecommendationsRequested',
      build: () {
        when(() => aiRepo.getAthleteRecommendations(
              athleteId: 'ath1',
              context: any(named: 'context'),
            )).thenAnswer(
          (_) async => makeAiResult(type: 'recommendations'),
        );
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const AiAthleteRecommendationsRequested('ath1')),
      expect: () => [
        isA<AiAthleteLoading>(),
        isA<AiAthleteLoaded>()
            .having((s) => s.result.type, 'type', 'recommendations'),
      ],
      verify: (_) => verify(() => aiRepo.getAthleteRecommendations(
            athleteId: 'ath1',
            context: any(named: 'context'),
          )).called(1),
    );

    blocTest<AiAthleteBloc, AiAthleteState>(
      'emits [Loading, Loaded] on AiAthleteAnalysisRequested',
      build: () {
        when(() => aiRepo.getAthleteAnalysis(
              athleteId: 'ath1',
              context: any(named: 'context'),
            )).thenAnswer(
          (_) async => makeAiResult(type: 'analysis'),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AiAthleteAnalysisRequested('ath1')),
      expect: () => [
        isA<AiAthleteLoading>(),
        isA<AiAthleteLoaded>()
            .having((s) => s.result.type, 'type', 'analysis'),
      ],
    );

    blocTest<AiAthleteBloc, AiAthleteState>(
      'emits [Loading, Error] on recommendations failure',
      build: () {
        when(() => aiRepo.getAthleteRecommendations(
              athleteId: any(named: 'athleteId'),
              context: any(named: 'context'),
            )).thenThrow(Exception('AI unavailable'));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const AiAthleteRecommendationsRequested('ath1')),
      expect: () => [
        isA<AiAthleteLoading>(),
        isA<AiAthleteError>().having(
          (s) => s.message,
          'message',
          'Не удалось получить рекомендации от ИИ',
        ),
      ],
    );

    blocTest<AiAthleteBloc, AiAthleteState>(
      'emits [Loading, Error] on analysis failure',
      build: () {
        when(() => aiRepo.getAthleteAnalysis(
              athleteId: any(named: 'athleteId'),
              context: any(named: 'context'),
            )).thenThrow(Exception('AI unavailable'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AiAthleteAnalysisRequested('ath1')),
      expect: () => [
        isA<AiAthleteLoading>(),
        isA<AiAthleteError>().having(
          (s) => s.message,
          'message',
          'Не удалось получить анализ от ИИ',
        ),
      ],
    );
  });
}
