import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/repository_providers.dart';
import '../bloc/ai_athlete_bloc.dart';

class AiAthleteScreen extends ConsumerWidget {
  const AiAthleteScreen({super.key, required this.athleteId});
  final String athleteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocProvider(
      create: (_) => AiAthleteBloc(
        repository: ref.read(aiRepositoryProvider),
      ),
      child: _AiAthleteView(athleteId: athleteId),
    );
  }
}

class _AiAthleteView extends StatelessWidget {
  const _AiAthleteView({required this.athleteId});
  final String athleteId;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('ai.analysis'.tr()),
          bottom: TabBar(
            tabs: [
              Tab(text: 'ai.recommendations'.tr()),
              Tab(text: 'ai.analysis'.tr()),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _AiTab(
              athleteId: athleteId,
              type: 'recommendations',
              buttonLabel: 'ai.getRecommendations'.tr(),
              hint: 'ai.recommendationsHint'.tr(),
            ),
            _AiTab(
              athleteId: athleteId,
              type: 'analysis',
              buttonLabel: 'ai.startAnalysis'.tr(),
              hint: 'ai.analysisHint'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiTab extends StatelessWidget {
  const _AiTab({
    required this.athleteId,
    required this.type,
    required this.buttonLabel,
    required this.hint,
  });

  final String athleteId;
  final String type;
  final String buttonLabel;
  final String hint;

  void _request(BuildContext context) {
    if (type == 'recommendations') {
      context
          .read<AiAthleteBloc>()
          .add(AiAthleteRecommendationsRequested(athleteId));
    } else {
      context
          .read<AiAthleteBloc>()
          .add(AiAthleteAnalysisRequested(athleteId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiAthleteBloc, AiAthleteState>(
      builder: (context, state) {
        return switch (state) {
          AiAthleteInitial() => _InitialView(
              hint: hint,
              buttonLabel: buttonLabel,
              onTap: () => _request(context),
            ),
          AiAthleteLoading() => const _LoadingView(),
          AiAthleteLoaded(:final result)
              when result.type == type =>
            _ResultView(
              content: result.content,
              model: result.model,
              generatedAt: result.generatedAt,
              onRefresh: () => _request(context),
            ),
          AiAthleteLoaded() => _InitialView(
              hint: hint,
              buttonLabel: buttonLabel,
              onTap: () => _request(context),
            ),
          AiAthleteError(:final message) => _ErrorView(
              message: message,
              onRetry: () => _request(context),
            ),
        };
      },
    );
  }
}

class _InitialView extends StatelessWidget {
  const _InitialView({
    required this.hint,
    required this.buttonLabel,
    required this.onTap,
  });

  final String hint;
  final String buttonLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.psychology_outlined,
                size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'ai.modelInfo'.tr(),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.auto_awesome),
              label: Text(buttonLabel),
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
            'ai.analyzing'.tr(),
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            'ai.mayTakeTime'.tr(),
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
            Text(
              '${'ai.generatedAt'.tr()} $hour:$minute · $model',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[600]),
            ),
            const Spacer(),
            TextButton(onPressed: onRefresh, child: Text('ai.refresh'.tr())),
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

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: Text('common.retry'.tr())),
          ],
        ),
      ),
    );
  }
}
