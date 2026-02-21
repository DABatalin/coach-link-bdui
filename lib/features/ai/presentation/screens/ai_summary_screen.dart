import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/repository_providers.dart';
import '../bloc/ai_summary_bloc.dart';

class AiSummaryScreen extends ConsumerWidget {
  const AiSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocProvider(
      create: (_) => AiSummaryBloc(
        repository: ref.read(aiRepositoryProvider),
      ),
      child: const _AiSummaryView(),
    );
  }
}

class _AiSummaryView extends StatelessWidget {
  const _AiSummaryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ИИ-сводка команды')),
      body: BlocBuilder<AiSummaryBloc, AiSummaryState>(
        builder: (context, state) => switch (state) {
          AiSummaryInitial() => _InitialView(
              onRequest: () => context
                  .read<AiSummaryBloc>()
                  .add(const AiSummaryRequested()),
            ),
          AiSummaryLoading() => const _LoadingView(),
          AiSummaryLoaded(:final result) => _ResultView(
              content: result.content,
              model: result.model,
              generatedAt: result.generatedAt,
              onRefresh: () => context
                  .read<AiSummaryBloc>()
                  .add(const AiSummaryRequested()),
            ),
          AiSummaryError(:final message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<AiSummaryBloc>()
                          .add(const AiSummaryRequested()),
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
            ),
        },
      ),
    );
  }
}

class _InitialView extends StatelessWidget {
  const _InitialView({required this.onRequest});
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.groups_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'ИИ соберёт отчёты всех спортсменов за последние 7 дней '
              'и выделит ключевые тенденции, проблемы и рекомендации.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Модель: gemma3:4b · ~3 мин на CPU',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRequest,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Сгенерировать сводку'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'ИИ анализирует отчёты команды…',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            'Это может занять до 3 минут',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.content,
    required this.model,
    required this.generatedAt,
    required this.onRefresh,
  });

  final String content;
  final String model;
  final DateTime generatedAt;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final day = generatedAt.day.toString().padLeft(2, '0');
    final month = generatedAt.month.toString().padLeft(2, '0');
    final hour = generatedAt.hour.toString().padLeft(2, '0');
    final minute = generatedAt.minute.toString().padLeft(2, '0');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome,
                size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '$day.$month $hour:$minute · $model',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey[600]),
              ),
            ),
            TextButton(onPressed: onRefresh, child: const Text('Обновить')),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }
}
