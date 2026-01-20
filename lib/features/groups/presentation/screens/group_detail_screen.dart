import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/repository_providers.dart';
import '../bloc/group_detail_bloc.dart';

class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({super.key, required this.groupId});
  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocProvider(
      create: (_) => GroupDetailBloc(
        repository: ref.read(groupsRepositoryProvider),
      )..add(GroupDetailLoadRequested(groupId)),
      child: _GroupDetailView(groupId: groupId),
    );
  }
}

class _GroupDetailView extends StatelessWidget {
  const _GroupDetailView({required this.groupId});
  final String groupId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupDetailBloc, GroupDetailState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              state is GroupDetailLoaded ? state.group.name : 'Группа',
            ),
          ),
          body: switch (state) {
            GroupDetailInitial() ||
            GroupDetailLoading() =>
              const Center(child: CircularProgressIndicator()),
            GroupDetailLoaded(:final group) => group.members.isEmpty
                ? const Center(child: Text('В группе нет спортсменов'))
                : ListView.builder(
                    itemCount: group.members.length,
                    itemBuilder: (context, index) {
                      final member = group.members[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            member.fullName.isNotEmpty
                                ? member.fullName[0]
                                : '?',
                          ),
                        ),
                        title: Text(member.fullName),
                        subtitle: Text('@${member.login}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline,
                              color: Colors.red),
                          onPressed: () => context
                              .read<GroupDetailBloc>()
                              .add(GroupMemberRemoved(
                                groupId: group.id,
                                athleteId: member.athleteId,
                              )),
                        ),
                      );
                    },
                  ),
            GroupDetailError(:final message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<GroupDetailBloc>()
                          .add(GroupDetailLoadRequested(groupId)),
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
          },
        );
      },
    );
  }
}
