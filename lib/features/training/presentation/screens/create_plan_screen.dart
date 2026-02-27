import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/repository_providers.dart';
import '../../../../core/navigation/routes.dart';
import '../../../connections/domain/models/athlete_info.dart';
import '../../../groups/domain/models/training_group.dart';

enum _TargetMode { athletes, group }

class CreatePlanScreen extends ConsumerStatefulWidget {
  const CreatePlanScreen({super.key, this.preselectedGroupId});

  final String? preselectedGroupId;

  @override
  ConsumerState<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends ConsumerState<CreatePlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));

  late _TargetMode _targetMode;
  List<AthleteInfo> _athletes = [];
  List<TrainingGroupSummary> _groups = [];
  final Set<String> _selectedAthleteIds = {};
  late String? _selectedGroupId;

  bool _isLoadingTargets = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.preselectedGroupId != null) {
      _targetMode = _TargetMode.group;
      _selectedGroupId = widget.preselectedGroupId;
    } else {
      _targetMode = _TargetMode.athletes;
      _selectedGroupId = null;
    }
    _loadTargets();
  }

  Future<void> _loadTargets() async {
    try {
      final results = await Future.wait([
        ref.read(connectionsRepositoryProvider).getCoachAthletes(),
        ref.read(groupsRepositoryProvider).getGroups(pageSize: 50),
      ]);
      if (mounted) {
        setState(() {
          _athletes = (results[0] as dynamic).items as List<AthleteInfo>;
          _groups = (results[1] as dynamic).items as List<TrainingGroupSummary>;
          _isLoadingTargets = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingTargets = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('training.createPlan'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'training.trainingTitle'.tr(),
                  hintText: 'training.trainingTitleHint'.tr(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'training.enterTitle'.tr() : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'training.trainingDescription'.tr(),
                  hintText: 'training.trainingDescriptionHint'.tr(),
                  alignLabelWithHint: true,
                ),
                maxLines: 6,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'training.enterDescription'.tr() : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text('training.trainingDate'.tr()),
                subtitle: Text(
                  '${_selectedDate.day.toString().padLeft(2, '0')}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.year}',
                ),
                onTap: _pickDate,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text('training.assignTo'.tr(),
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<_TargetMode>(
                segments: [
                  ButtonSegment(
                    value: _TargetMode.athletes,
                    label: Text('connections.athletes'.tr()),
                    icon: const Icon(Icons.person),
                  ),
                  ButtonSegment(
                    value: _TargetMode.group,
                    label: Text('training.group'.tr()),
                    icon: const Icon(Icons.group),
                  ),
                ],
                selected: {_targetMode},
                onSelectionChanged: (s) =>
                    setState(() => _targetMode = s.first),
              ),
              const SizedBox(height: 12),
              if (_isLoadingTargets)
                const Center(child: CircularProgressIndicator())
              else if (_targetMode == _TargetMode.athletes)
                _buildAthletesList()
              else
                _buildGroupsList(),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text('training.createAndAssign'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAthletesList() {
    if (_athletes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text('training.noConnectedAthletes'.tr()),
      );
    }
    return Column(
      children: _athletes.map((a) {
        final selected = _selectedAthleteIds.contains(a.id);
        return CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(a.fullName),
          subtitle: Text(a.login),
          value: selected,
          onChanged: (v) {
            setState(() {
              if (v == true) {
                _selectedAthleteIds.add(a.id);
              } else {
                _selectedAthleteIds.remove(a.id);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildGroupsList() {
    if (_groups.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text('training.noGroups'.tr()),
      );
    }
    return Column(
      children: _groups.map((g) {
        return RadioListTile<String>(
          contentPadding: EdgeInsets.zero,
          title: Text(g.name),
          subtitle: Text('${g.membersCount}${'training.people'.tr()}'),
          value: g.id,
          groupValue: _selectedGroupId,
          onChanged: (v) => setState(() => _selectedGroupId = v),
        );
      }).toList(),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final hasTarget = _targetMode == _TargetMode.athletes
        ? _selectedAthleteIds.isNotEmpty
        : _selectedGroupId != null;

    if (!hasTarget) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(
            _targetMode == _TargetMode.athletes
                ? 'training.selectAtLeastOneAthlete'.tr()
                : 'training.selectGroup'.tr(),
          ),
        ));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(trainingRepositoryProvider);
      await repo.createPlan(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        scheduledDate: _selectedDate,
        athleteIds: _targetMode == _TargetMode.athletes
            ? _selectedAthleteIds.toList()
            : null,
        groupId: _targetMode == _TargetMode.group ? _selectedGroupId : null,
      );
      if (mounted) context.go(AppRoutes.coachAssignments);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text('training.failedToCreatePlan'.tr()),
          ));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
