import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/analytics_providers.dart';
import '../../../../core/di/repository_providers.dart';
import '../bloc/find_coach_bloc.dart';

class FindCoachScreen extends ConsumerWidget {
  const FindCoachScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocProvider(
      create: (_) => FindCoachBloc(
        repository: ref.read(connectionsRepositoryProvider),
        analytics: ref.read(analyticsServiceProvider),
      ),
      child: const _FindCoachView(),
    );
  }
}

class _FindCoachView extends StatelessWidget {
  const _FindCoachView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Поиск тренера')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Введите ФИО или логин тренера',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => context
                  .read<FindCoachBloc>()
                  .add(FindCoachQueryChanged(value)),
            ),
          ),
          Expanded(
            child: BlocConsumer<FindCoachBloc, FindCoachState>(
              listener: (context, state) {
                if (state.successMessage != null) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                      content: Text(state.successMessage!),
                      backgroundColor: Colors.green,
                    ));
                }
                if (state.errorMessage != null) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                      content: Text(state.errorMessage!),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ));
                }
              },
              builder: (context, state) {
                if (state.isSearching) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.query.length < 2) {
                  return const Center(
                    child: Text('Введите минимум 2 символа для поиска'),
                  );
                }
                if (state.results.isEmpty) {
                  return const Center(child: Text('Ничего не найдено'));
                }
                return ListView.builder(
                  itemCount: state.results.length,
                  itemBuilder: (context, index) {
                    final coach = state.results[index];
                    final isSent = state.sentCoachId == coach.id;
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(coach.fullName.isNotEmpty
                            ? coach.fullName[0]
                            : '?'),
                      ),
                      title: Text(coach.fullName),
                      subtitle: Text('@${coach.login}'),
                      trailing: isSent
                          ? const Chip(label: Text('Отправлено'))
                          : IconButton(
                              icon: const Icon(Icons.person_add),
                              onPressed: state.isSending
                                  ? null
                                  : () => context
                                      .read<FindCoachBloc>()
                                      .add(FindCoachRequestSent(coach.id)),
                            ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
