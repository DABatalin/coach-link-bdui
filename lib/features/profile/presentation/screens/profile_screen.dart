import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/di/auth_providers.dart';
import '../../../../core/di/repository_providers.dart';
import '../../../../core/l10n/language_service.dart';
import '../../../../core/l10n/language_selector.dart';
import '../bloc/profile_bloc.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocProvider(
      create: (_) => ProfileBloc(
        repository: ref.read(profileRepositoryProvider),
        authManager: ref.read(authManagerProvider),
      )..add(const ProfileLoadRequested()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('profile.title'.tr())),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          return switch (state) {
            ProfileInitial() || ProfileLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            ProfileLoaded(:final user) => ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 16),
                  CircleAvatar(
                    radius: 48,
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    child: Text(
                      user.fullName.isNotEmpty
                          ? user.fullName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 36,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.fullName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.isCoach ? 'profile.coach'.tr() : 'profile.athlete'.tr(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 32),
                  _InfoTile(
                    icon: Icons.person_outline,
                    label: 'profile.loginLabel'.tr(),
                    value: user.login,
                  ),
                  _InfoTile(
                    icon: Icons.email_outlined,
                    label: 'profile.emailLabel'.tr(),
                    value: user.email,
                  ),
                  _InfoTile(
                    icon: Icons.calendar_today_outlined,
                    label: 'profile.registrationDate'.tr(),
                    value:
                        '${user.createdAt.day.toString().padLeft(2, '0')}.${user.createdAt.month.toString().padLeft(2, '0')}.${user.createdAt.year}',
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text('profile.language'.tr()),
                    trailing: Consumer(
                      builder: (context, ref, _) {
                        final languageService = ref.read(languageServiceProvider);
                        final currentLanguage = languageService.getCurrentLanguage(context);
                        return Text(currentLanguage.name);
                      },
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => const LanguageSelectorDialog(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => context
                        .read<ProfileBloc>()
                        .add(const ProfileLogoutRequested()),
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: Text(
                      'profile.logoutButton'.tr(),
                      style: const TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ProfileError(:final message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<ProfileBloc>()
                          .add(const ProfileLoadRequested()),
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

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(label, style: Theme.of(context).textTheme.bodySmall),
      subtitle: Text(value, style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}
