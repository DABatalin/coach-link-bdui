import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/repository_providers.dart';
import '../bloc/groups_bloc.dart';

class GroupsListScreen extends ConsumerWidget {
  const GroupsListScreen({super.key, this.isCoach = false});

  final bool isCoach;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocProvider(
      create: (_) => GroupsBloc(
        repository: ref.read(groupsRepositoryProvider),
      )..add(const GroupsLoadRequested()),
      child: _GroupsView(isCoach: isCoach),
    );
  }
}

class _GroupsView extends StatelessWidget {
  const _GroupsView({required this.isCoach});

  final bool isCoach;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('groups.title'.tr())),
      floatingActionButton: isCoach
          ? FloatingActionButton(
              onPressed: () => _showCreateDialog(context),
              child: const Icon(Icons.add),
            )
          : null,
      body: BlocBuilder<GroupsBloc, GroupsState>(
        builder: (context, state) {
          return switch (state) {
            GroupsInitial() || GroupsLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            GroupsLoaded(:final groups) => groups.isEmpty
                ? Center(
                    child: Text(
                      isCoach
                          ? 'groups.noGroups'.tr()
                          : 'groups.notInAnyGroup'.tr(),
                    ),
                  )
                : ListView.builder(
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      return ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.groups),
                        ),
                        title: Text(group.name),
                        subtitle: Text('${group.membersCount}${'groups.athletes'.tr()}'),
                        trailing: isCoach
                            ? const Icon(Icons.chevron_right)
                            : null,
                        onTap: isCoach
                            ? () => context.go('/coach/groups/${group.id}')
                            : null,
                      );
                    },
                  ),
            GroupsError(:final message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<GroupsBloc>()
                          .add(const GroupsLoadRequested()),
                      child: Text('common.retry'.tr()),
                    ),
                  ],
                ),
              ),
          };
        },
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('groups.newGroup'.tr()),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'groups.groupName'.tr(),
            hintText: 'groups.groupNameHint'.tr(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('common.cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                context.read<GroupsBloc>().add(GroupCreated(name));
                Navigator.pop(dialogContext);
              }
            },
            child: Text('common.create'.tr()),
          ),
        ],
      ),
    );
  }
}
