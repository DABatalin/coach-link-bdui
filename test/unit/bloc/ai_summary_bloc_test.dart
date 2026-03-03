import 'package:bloc_test/bloc_test.dart';
import 'package:coach_link/features/ai/presentation/bloc/ai_summary_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_repositories.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockAiRepository aiRepo;

  setUp(() {
    aiRepo = MockAiRepository();
  });

  AiSummaryBloc buildBloc() => AiSummaryBloc(repository: aiRepo);

  group('AiSummaryBloc', () {
    test('initial state is AiSummaryInitial', () {
      expect(buildBloc().state, isA<AiSummaryInitial>());
    });

    blocTest<AiSummaryBloc, AiSummaryState>(
      'emits [Loading, Loaded] on AiSummaryRequested without date range',
      build: () {
        when(() => aiRepo.getCoachSummary(
              dateFrom: any(named: 'dateFrom'),
              dateTo: any(named: 'dateTo'),
              context: any(named: 'context'),
            )).thenAnswer((_) async => makeAiResult(type: 'summary'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AiSummaryRequested()),
      expect: () => [
        isA<AiSummaryLoading>(),
        isA<AiSummaryLoaded>()
            .having((s) => s.result.type, 'type', 'summary'),
      ],
      verify: (_) => verify(() => aiRepo.getCoachSummary(
            dateFrom: any(named: 'dateFrom'),
            dateTo: any(named: 'dateTo'),
            context: any(named: 'context'),
          )).called(1),
    );

    blocTest<AiSummaryBloc, AiSummaryState>(
      'emits [Loading, Loaded] on AiSummaryRequested with date range',
      build: () {
        when(() => aiRepo.getCoachSummary(
              dateFrom: any(named: 'dateFrom'),
              dateTo: any(named: 'dateTo'),
              context: any(named: 'context'),
            )).thenAnswer((_) async => makeAiResult(type: 'summary'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(AiSummaryRequested(
        dateFrom: kNow,
        dateTo: kFuture,
      )),
      expect: () => [
        isA<AiSummaryLoading>(),
        isA<AiSummaryLoaded>(),
      ],
    );

    blocTest<AiSummaryBloc, AiSummaryState>(
      'emits [Loading, Error] when repository throws',
      build: () {
        when(() => aiRepo.getCoachSummary(
              dateFrom: any(named: 'dateFrom'),
              dateTo: any(named: 'dateTo'),
              context: any(named: 'context'),
            )).thenThrow(Exception('AI unavailable'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AiSummaryRequested()),
      expect: () => [
        isA<AiSummaryLoading>(),
        isA<AiSummaryError>().having(
          (s) => s.message,
          'message',
          'Не удалось получить сводку от ИИ',
        ),
      ],
    );
  });
}
