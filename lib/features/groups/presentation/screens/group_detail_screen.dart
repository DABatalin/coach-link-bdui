import 'package:coach_link/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/repository_providers.dart';
import '../../../../core/navigation/routes.dart';
import '../../../connections/domain/models/athlete_info.dart';
import '../../../training/domain/models/assignment.dart';
import '../bloc/group_detail_bloc.dart';

class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({super.key, required this.groupId});
  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocProvider(
      create: (_) => GroupDetailBloc(
        repository: ref.read(groupsRepositoryProvider),
        trainingRepository: ref.read(trainingRepositoryProvider),
      )..add(GroupDetailLoadRequested(groupId)),
      child: _GroupDetailView(groupId: groupId, ref: ref),
    );
  }
}

class _GroupDetailView extends StatefulWidget {
  const _GroupDetailView({required this.groupId, required this.ref});
  final String groupId;
  final WidgetRef ref;

  @override
  State<_GroupDetailView> createState() => _GroupDetailViewState();
}

class _GroupDetailViewState extends State<_GroupDetailView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAssignmentsTab = _tabController.index == 1;

    return BlocBuilder<GroupDetailBloc, GroupDetailState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              state is GroupDetailLoaded ? state.group.name : 'Группа',
            ),
            bottom: TabBar(
              unselectedLabelColor: AppColors.textHint,
              labelColor: AppColors.accent,
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.people), text: 'Участники', ),
                Tab(icon: Icon(Icons.assignment), text: 'Задания'),
              ],
            ),
          ),
          floatingActionButton: isAssignmentsTab
              ? FloatingActionButton.extended(
                  onPressed: () => context.go(
                    '${AppRoutes.coachPlanCreate}?group_id=${widget.groupId}',
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Выдать задание'),
                )
              : FloatingActionButton(
                  onPressed: () => _showAddMemberSheet(context, state),
                  child: const Icon(Icons.person_add),
                ),
          body: switch (state) {
            GroupDetailInitial() ||
            GroupDetailLoading() =>
              const Center(child: CircularProgressIndicator()),
            GroupDetailLoaded(:final group, :final assignments) => TabBarView(
                controller: _tabController,
                children: [
                  _MembersTab(
                    group: group,
                    onRemove: (athleteId) =>
                        context.read<GroupDetailBloc>().add(GroupMemberRemoved(
                              groupId: group.id,
                              athleteId: athleteId,
                            )),
                  ),
                  _AssignmentsTab(
                    assignments: assignments,
                    groupId: widget.groupId,
                  ),
                ],
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
                          .add(GroupDetailLoadRequested(widget.groupId)),
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
        existingMemberIds: existingIds,
        connectionsRepository: widget.ref.read(connectionsRepositoryProvider),
        onAdd: (athleteId) {
          context.read<GroupDetailBloc>().add(GroupMemberAdded(
                groupId: widget.groupId,
                athleteId: athleteId,
              ));
        },
      ),
    );
  }
}

// ── Вкладка участников ────────────────────────────────────────────────────────

class _MembersTab extends StatelessWidget {
  const _MembersTab({required this.group, required this.onRemove});
  final dynamic group;
  final void Function(String athleteId) onRemove;

  @override
  Widget build(BuildContext context) {
    if (group.members.isEmpty) {
      return const Center(child: Text('В группе нет спортсменов'));
    }
    return ListView.builder(
      itemCount: group.members.length,
      itemBuilder: (context, index) {
        final member = group.members[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(
              member.fullName.isNotEmpty ? member.fullName[0] : '?',
            ),
          ),
          title: Text(member.fullName),
          subtitle: Text('@${member.login}'),
          trailing: IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
            onPressed: () => onRemove(member.athleteId),
          ),
        );
      },
    );
  }
}

// ── Вкладка заданий ──────────────────────────────────────────────────────────

class _AssignmentsTab extends StatelessWidget {
  const _AssignmentsTab({
    required this.assignments,
    required this.groupId,
  });
  final List<AssignmentListItem> assignments;
  final String groupId;

  @override
  Widget build(BuildContext context) {
    if (assignments.isEmpty) {
      return const Center(child: Text('Нет заданий для этой группы'));
    }
    return ListView.builder(
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final a = assignments[index];
        final date = a.scheduledDate;
        final dateStr =
            '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

        IconData icon;
        Color? iconColor;
        if (a.isOverdue) {
          icon = Icons.warning_amber;
          iconColor = Colors.red;
        } else if (a.hasReport) {
          icon = Icons.check_circle;
          iconColor = Colors.green;
        } else {
          icon = Icons.assignment;
          iconColor = null;
        }

        return ListTile(
          leading: Icon(icon, color: iconColor),
          title: Text(a.title),
          subtitle: Text(dateStr),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go('/coach/assignments/${a.id}'),
        );
      },
    );
  }
}

// ── Шторка добавления участника ───────────────────────────────────────────────

class _AddMemberSheet extends StatefulWidget {
  const _AddMemberSheet({
    required this.existingMemberIds,
    required this.connectionsRepository,
    required this.onAdd,
  });

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
      if (mounted) {
        setState(() {
          _available = all
              .where((a) => !widget.existingMemberIds.contains(a.id))
              .toList();
          _isLoading = false;
        });
      }
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
                      ? const Center(child: Text('Все спортсмены уже в группе'))
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
                              trailing:
                                  const Icon(Icons.add_circle_outline),
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
