import 'package:bloc_test/bloc_test.dart';
import 'package:coach_link/features/training/presentation/bloc/templates_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_repositories.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockTrainingRepository trainingRepo;

  setUp(() {
    trainingRepo = MockTrainingRepository();
  });

  TemplatesBloc buildBloc() => TemplatesBloc(repository: trainingRepo);

  group('TemplatesBloc', () {
    test('initial state is TemplatesInitial', () {
      expect(buildBloc().state, isA<TemplatesInitial>());
    });

    blocTest<TemplatesBloc, TemplatesState>(
      'emits [Loading, Loaded] with templates list',
      build: () {
        when(() => trainingRepo.getTemplates()).thenAnswer(
          (_) async => makePaginated([
            makeTemplate(id: 't1'),
            makeTemplate(id: 't2'),
          ]),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const TemplatesLoadRequested()),
      expect: () => [
        isA<TemplatesLoading>(),
        isA<TemplatesLoaded>().having((s) => s.templates.length, 'length', 2),
      ],
    );

    blocTest<TemplatesBloc, TemplatesState>(
      'emits [Loading, Loaded(empty)] when no templates',
      build: () {
        when(() => trainingRepo.getTemplates())
            .thenAnswer((_) async => makePaginated([]));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const TemplatesLoadRequested()),
      expect: () => [
        isA<TemplatesLoading>(),
        isA<TemplatesLoaded>()
            .having((s) => s.templates, 'templates', isEmpty),
      ],
    );

    blocTest<TemplatesBloc, TemplatesState>(
      'emits [Loading, Error] when repository throws',
      build: () {
        when(() => trainingRepo.getTemplates())
            .thenThrow(Exception('Network error'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const TemplatesLoadRequested()),
      expect: () => [isA<TemplatesLoading>(), isA<TemplatesError>()],
    );

    blocTest<TemplatesBloc, TemplatesState>(
      'TemplateCreated calls createTemplate and reloads list',
      build: () {
        when(() => trainingRepo.createTemplate(
              title: 'New Template',
              description: 'Desc',
            )).thenAnswer((_) async => makeTemplate(id: 't3'));
        when(() => trainingRepo.getTemplates()).thenAnswer(
          (_) async => makePaginated([makeTemplate(id: 't3')]),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const TemplateCreated(title: 'New Template', description: 'Desc'),
      ),
      expect: () => [
        isA<TemplatesLoading>(),
        isA<TemplatesLoaded>()
            .having((s) => s.templates.length, 'length', 1),
      ],
      verify: (_) => verify(() => trainingRepo.createTemplate(
            title: 'New Template',
            description: 'Desc',
          )).called(1),
    );

    blocTest<TemplatesBloc, TemplatesState>(
      'TemplateDeleted calls deleteTemplate and reloads list',
      build: () {
        when(() => trainingRepo.deleteTemplate(templateId: 't1'))
            .thenAnswer((_) async {});
        when(() => trainingRepo.getTemplates())
            .thenAnswer((_) async => makePaginated([]));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const TemplateDeleted('t1')),
      verify: (_) =>
          verify(() => trainingRepo.deleteTemplate(templateId: 't1')).called(1),
    );
  });
}
