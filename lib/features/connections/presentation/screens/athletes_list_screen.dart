import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/repository_providers.dart';
import '../bloc/athletes_bloc.dart';

class AthletesListScreen extends ConsumerWidget {
  const AthletesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocProvider(
      create: (_) => AthletesBloc(
        repository: ref.read(connectionsRepositoryProvider),
      )..add(const AthletesLoadRequested()),
      child: const _AthletesView(),
    );
  }
}

class _AthletesView extends StatelessWidget {
  const _AthletesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои спортсмены')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Поиск по ФИО или логину',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => context
                  .read<AthletesBloc>()
                  .add(AthletesSearchChanged(value)),
            ),
          ),
          Expanded(
            child: BlocBuilder<AthletesBloc, AthletesState>(
              builder: (context, state) {
                return switch (state) {
                  AthletesInitial() || AthletesLoading() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  AthletesLoaded(:final athletes) => athletes.isEmpty
                      ? const Center(child: Text('Нет спортсменов'))
                      : ListView.builder(
                          itemCount: athletes.length,
                          itemBuilder: (context, index) {
                            final athlete = athletes[index];
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  athlete.fullName.isNotEmpty
                                      ? athlete.fullName[0]
                                      : '?',
                                ),
                              ),
                              title: Text(athlete.fullName),
                              subtitle: Text('@${athlete.login}'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => context.go(
                                '/coach/athletes/${athlete.id}',
                              ),
                            );
                          },
                        ),
                  AthletesError(:final message) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(message),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context
                                .read<AthletesBloc>()
                                .add(const AthletesLoadRequested()),
                            child: const Text('Повторить'),
                          ),
                        ],
                      ),
                    ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}
