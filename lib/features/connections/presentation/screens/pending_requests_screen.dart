import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/repository_providers.dart';
import '../bloc/requests_bloc.dart';

class PendingRequestsScreen extends ConsumerWidget {
  const PendingRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocProvider(
      create: (_) => RequestsBloc(
        repository: ref.read(connectionsRepositoryProvider),
      )..add(const RequestsLoadRequested()),
      child: const _RequestsView(),
    );
  }
}

class _RequestsView extends StatelessWidget {
  const _RequestsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('connections.pendingRequests'.tr())),
      body: BlocBuilder<RequestsBloc, RequestsState>(
        builder: (context, state) {
          return switch (state) {
            RequestsInitial() || RequestsLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            RequestsLoaded(:final requests) => requests.isEmpty
                ? Center(child: Text('connections.noRequests'.tr()))
                : ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            request.athlete.fullName.isNotEmpty
                                ? request.athlete.fullName[0]
                                : '?',
                          ),
                        ),
                        title: Text(request.athlete.fullName),
                        subtitle: Text('@${request.athlete.login}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check_circle,
                                  color: Colors.green),
                              onPressed: () => context
                                  .read<RequestsBloc>()
                                  .add(RequestAccepted(request.id)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel,
                                  color: Colors.red),
                              onPressed: () => context
                                  .read<RequestsBloc>()
                                  .add(RequestRejected(request.id)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            RequestsError(:final message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<RequestsBloc>()
                          .add(const RequestsLoadRequested()),
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
}
