import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/repository_providers.dart';
import '../../../connections/domain/models/athlete_info.dart';
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
      child: _GroupDetailView(
        groupId: groupId,
        ref: ref,
      ),
    );
  }
}

class _GroupDetailView extends StatelessWidget {
  const _GroupDetailView({required this.groupId, required this.ref});

  final String groupId;
  final WidgetRef ref;

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
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddMemberSheet(context, state),
            child: const Icon(Icons.person_add),
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

  void _showAddMemberSheet(BuildContext context, GroupDetailState state) {
    final existingIds = state is GroupDetailLoaded
        ? state.group.members.map((m) => m.athleteId).toSet()
        : <String>{};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddMemberSheet(
        groupId: groupId,
        existingMemberIds: existingIds,
        connectionsRepository: ref.read(connectionsRepositoryProvider),
        onAdd: (athleteId) {
          context.read<GroupDetailBloc>().add(GroupMemberAdded(
                groupId: groupId,
                athleteId: athleteId,
              ));
        },
      ),
    );
  }
}

class _AddMemberSheet extends StatefulWidget {
  const _AddMemberSheet({
    required this.groupId,
    required this.existingMemberIds,
    required this.connectionsRepository,
    required this.onAdd,
  });

  final String groupId;
  final Set<String> existingMemberIds;
  final dynamic connectionsRepository;
  final void Function(String athleteId) onAdd;

  @override
  State<_AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends State<_AddMemberSheet> {
  List<AthleteInfo> _available = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final result =
          await widget.connectionsRepository.getCoachAthletes(pageSize: 100);
      final all = result.items as List<AthleteInfo>;
      setState(() {
        _available =
            all.where((a) => !widget.existingMemberIds.contains(a.id)).toList();
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Добавить спортсмена',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _available.isEmpty
                      ? const Center(
                          child: Text('Все спортсмены уже в группе'),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: _available.length,
                          itemBuilder: (_, index) {
                            final athlete = _available[index];
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
                              trailing: const Icon(Icons.add_circle_outline),
                              onTap: () {
                                widget.onAdd(athlete.id);
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }
}
