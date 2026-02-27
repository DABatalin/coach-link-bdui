import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/di/repository_providers.dart';
import '../bloc/templates_bloc.dart';

class TemplatesScreen extends ConsumerWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocProvider(
      create: (_) => TemplatesBloc(
        repository: ref.read(trainingRepositoryProvider),
      )..add(const TemplatesLoadRequested()),
      child: const _TemplatesView(),
    );
  }
}

class _TemplatesView extends StatelessWidget {
  const _TemplatesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('training.templates'.tr())),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<TemplatesBloc, TemplatesState>(
        builder: (context, state) {
          return switch (state) {
            TemplatesInitial() || TemplatesLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            TemplatesLoaded(:final templates) => templates.isEmpty
                ? Center(child: Text('training.noTemplates'.tr()))
                : ListView.builder(
                    itemCount: templates.length,
                    itemBuilder: (context, index) {
                      final t = templates[index];
                      return ListTile(
                        leading: const Icon(Icons.bookmark),
                        title: Text(t.title),
                        subtitle: Text(
                          t.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () => context
                              .read<TemplatesBloc>()
                              .add(TemplateDeleted(t.id)),
                        ),
                      );
                    },
                  ),
            TemplatesError(:final message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<TemplatesBloc>()
                          .add(const TemplatesLoadRequested()),
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
    final titleController = TextEditingController();
    final descController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('training.newTemplate'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'training.templateName'.tr()),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: InputDecoration(labelText: 'training.templateDescription'.tr()),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('common.cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final desc = descController.text.trim();
              if (title.isNotEmpty && desc.isNotEmpty) {
                context.read<TemplatesBloc>().add(
                    TemplateCreated(title: title, description: desc));
                Navigator.pop(dialogContext);
              }
            },
            child: Text('common.save'.tr()),
          ),
        ],
      ),
    );
  }
}
