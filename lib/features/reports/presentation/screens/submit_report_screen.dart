import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/repository_providers.dart';
import '../../../../core/navigation/routes.dart';
import '../bloc/submit_report_bloc.dart';

class SubmitReportScreen extends ConsumerWidget {
  const SubmitReportScreen({super.key, required this.assignmentId});
  final String assignmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocProvider(
      create: (_) => SubmitReportBloc(
        repository: ref.read(reportsRepositoryProvider),
      ),
      child: _SubmitReportView(assignmentId: assignmentId),
    );
  }
}

class _SubmitReportView extends StatefulWidget {
  const _SubmitReportView({required this.assignmentId});
  final String assignmentId;

  @override
  State<_SubmitReportView> createState() => _SubmitReportViewState();
}

class _SubmitReportViewState extends State<_SubmitReportView> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _durationController = TextEditingController();
  final _maxHrController = TextEditingController();
  final _avgHrController = TextEditingController();
  final _distanceController = TextEditingController();
  int _perceivedEffort = 5;

  @override
  void dispose() {
    _contentController.dispose();
    _durationController.dispose();
    _maxHrController.dispose();
    _avgHrController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Отчёт о тренировке')),
      body: BlocListener<SubmitReportBloc, SubmitReportState>(
        listener: (context, state) {
          if (state is SubmitReportSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(const SnackBar(
                content: Text('Отчёт отправлен'),
                backgroundColor: Colors.green,
              ));
            context.go(AppRoutes.athleteAssignments);
          }
          if (state is SubmitReportFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Комментарий',
                    hintText: 'Как прошла тренировка...',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Напишите комментарий' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(
                    labelText: 'Длительность (мин)',
                    prefixIcon: Icon(Icons.timer),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Укажите длительность';
                    final n = int.tryParse(v);
                    if (n == null || n < 1) return 'Минимум 1 минута';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Самочувствие (RPE): $_perceivedEffort / 10',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Slider(
                  value: _perceivedEffort.toDouble(),
                  min: 0,
                  max: 10,
                  divisions: 10,
                  label: '$_perceivedEffort',
                  onChanged: (v) =>
                      setState(() => _perceivedEffort = v.round()),
                ),
                const SizedBox(height: 16),
                Text(
                  'Дополнительно (необязательно)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _maxHrController,
                        decoration: const InputDecoration(
                          labelText: 'Макс. пульс',
                          suffixText: 'уд/мин',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _avgHrController,
                        decoration: const InputDecoration(
                          labelText: 'Сред. пульс',
                          suffixText: 'уд/мин',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _distanceController,
                  decoration: const InputDecoration(
                    labelText: 'Дистанция',
                    suffixText: 'км',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 32),
                BlocBuilder<SubmitReportBloc, SubmitReportState>(
                  builder: (context, state) {
                    final isLoading = state is SubmitReportLoading;
                    return ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Отправить отчёт'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<SubmitReportBloc>().add(ReportSubmitted(
          assignmentId: widget.assignmentId,
          content: _contentController.text.trim(),
          durationMinutes: int.parse(_durationController.text),
          perceivedEffort: _perceivedEffort,
          maxHeartRate: int.tryParse(_maxHrController.text),
          avgHeartRate: int.tryParse(_avgHrController.text),
          distanceKm: double.tryParse(_distanceController.text),
        ));
  }
}
