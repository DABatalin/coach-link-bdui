import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/di/repository_providers.dart';
import '../bloc/assignments_bloc.dart';

class ArchivedAssignmentsScreen extends ConsumerWidget {
  const ArchivedAssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocProvider(
      create: (_) => AssignmentsBloc(
        repository: ref.read(trainingRepositoryProvider),
      )..add(const AssignmentsLoadRequested()),
      child: const _ArchivedView(),
    );
  }
}

class _ArchivedView extends StatelessWidget {
  const _ArchivedView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('training.archived'.tr())),
      body: BlocBuilder<AssignmentsBloc, AssignmentsState>(
        builder: (context, state) {
          return switch (state) {
            AssignmentsInitial() || AssignmentsLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            AssignmentsLoaded(:final assignments) => assignments.isEmpty
                ? Center(child: Text('training.archiveEmpty'.tr()))
                : ListView.builder(
                    itemCount: assignments.length,
                    itemBuilder: (context, index) {
                      final a = assignments[index];
                      return ListTile(
                        leading: const Icon(Icons.archive, color: Colors.grey),
                        title: Text(a.title),
                        subtitle: Text(a.athleteFullName ?? ''),
                      );
                    },
                  ),
            AssignmentsError(:final message) => Center(child: Text(message)),
          };
        },
      ),
    );
  }
}
