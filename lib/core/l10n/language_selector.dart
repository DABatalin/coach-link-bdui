import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

import 'language_service.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageService = ref.read(languageServiceProvider);
    final currentLanguage = languageService.getCurrentLanguage(context);

    return DropdownButton<AppLanguage>(
      value: currentLanguage,
      items: AppLanguage.values.map((language) {
        return DropdownMenuItem<AppLanguage>(
          value: language,
          child: Text(language.name),
        );
      }).toList(),
      onChanged: (language) async {
        if (language != null) {
          await languageService.setLanguage(language, context);
        }
      },
    );
  }
}

class LanguageSelectorDialog extends ConsumerWidget {
  const LanguageSelectorDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageService = ref.read(languageServiceProvider);
    final currentLanguage = languageService.getCurrentLanguage(context);

    return AlertDialog(
      title: Text('profile.language'.tr()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: AppLanguage.values.map((language) {
          return RadioListTile<AppLanguage>(
            title: Text(language.name),
            value: language,
            groupValue: currentLanguage,
            onChanged: (selected) async {
              if (selected != null) {
                await languageService.setLanguage(selected, context);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('common.cancel'.tr()),
        ),
      ],
    );
  }
}
