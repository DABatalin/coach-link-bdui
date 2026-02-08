import 'package:bdui_kit/bdui_kit.dart';

import 'bdui_data_provider.dart';

/// Mock-реализация BduiDataProvider с хардкод-схемами.
class BduiDataProviderMock implements BduiDataProvider {
  @override
  Future<BduiSchema?> getSchema(String screenId) async {
    // Имитация задержки сети
    await Future.delayed(const Duration(milliseconds: 200));

    final builder = _schemas[screenId];
    if (builder == null) return null;
    return builder();
  }

  static final _schemas = <String, BduiSchema Function()>{
    'coach-dashboard': _coachDashboard,
    'athlete-dashboard': _athleteDashboard,
  };

  static BduiSchema _coachDashboard() {
    return BduiSchema.fromJson(const {
      'screen_id': 'coach-dashboard',
      'version': '1.0.0',
      'ttl_seconds': 300,
      'root': {
        'type': 'scroll_view',
        'props': {'padding': 16},
        'children': [
          {
            'type': 'text',
            'props': {'text': 'Добро пожаловать!', 'style': 'headline'},
          },
          {
            'type': 'spacer',
            'props': {'height': 16},
          },
          {
            'type': 'row',
            'props': {'spacing': 12},
            'children': [
              {
                'type': 'card',
                'id': 'athletes-count',
                'props': {
                  'title': 'Спортсмены',
                  'subtitle': '12 человек',
                  'icon': 'people',
                  'color': '#1976D2',
                },
                'action': {'type': 'navigate', 'route': '/coach/athletes'},
              },
              {
                'type': 'card',
                'id': 'pending-requests',
                'props': {
                  'title': 'Заявки',
                  'subtitle': 'Ожидают решения',
                  'icon': 'person_add',
                  'color': '#FF9800',
                  'badge': 3,
                },
                'action': {'type': 'navigate', 'route': '/coach/requests'},
              },
            ],
          },
          {
            'type': 'spacer',
            'props': {'height': 24},
          },
          {
            'type': 'list',
            'id': 'recent-reports',
            'props': {
              'title': 'Последние отчёты',
              'empty_text': 'Отчётов пока нет',
              'divider': true,
            },
            'children': [
              {
                'type': 'list_tile',
                'props': {
                  'title': 'Иванов Иван — Кросс 8 км',
                  'subtitle': 'RPE: 6/10 · 45 мин · 8.2 км',
                  'leading_icon': 'description',
                  'trailing_text': 'Вчера',
                },
              },
              {
                'type': 'list_tile',
                'props': {
                  'title': 'Петрова Анна — Интервалы 400м',
                  'subtitle': 'RPE: 8/10 · 35 мин',
                  'leading_icon': 'description',
                  'trailing_text': '2 дня назад',
                },
              },
            ],
          },
          {
            'type': 'spacer',
            'props': {'height': 24},
          },
          {
            'type': 'list',
            'id': 'upcoming-assignments',
            'props': {
              'title': 'Ближайшие задания',
              'empty_text': 'Нет запланированных заданий',
              'divider': true,
            },
            'children': [
              {
                'type': 'list_tile',
                'props': {
                  'title': 'Развивающий кросс',
                  'subtitle': '5 спортсменов',
                  'leading_icon': 'directions_run',
                },
              },
              {
                'type': 'list_tile',
                'props': {
                  'title': 'Темповый бег 3 км',
                  'subtitle': '3 спортсмена',
                  'leading_icon': 'timer',
                },
              },
            ],
          },
          {
            'type': 'spacer',
            'props': {'height': 24},
          },
          {
            'type': 'container',
            'props': {
              'padding': 16,
              'color': '#FFF3E0',
              'border_radius': 12,
            },
            'children': [
              {
                'type': 'text',
                'id': 'daily-tip',
                'props': {
                  'text':
                      'Не забывайте про восстановительные тренировки между интенсивными блоками!',
                  'style': 'tip',
                },
              },
            ],
          },
        ],
      },
    });
  }

  static BduiSchema _athleteDashboard() {
    return BduiSchema.fromJson(const {
      'screen_id': 'athlete-dashboard',
      'version': '1.0.0',
      'ttl_seconds': 300,
      'root': {
        'type': 'scroll_view',
        'props': {'padding': 16},
        'children': [
          {
            'type': 'text',
            'props': {'text': 'Добро пожаловать!', 'style': 'headline'},
          },
          {
            'type': 'spacer',
            'props': {'height': 16},
          },
          {
            'type': 'card',
            'id': 'my-coach',
            'props': {
              'title': 'Мой тренер',
              'subtitle': 'Смирнов Алексей Николаевич',
              'icon': 'sports',
            },
            'action': {'type': 'navigate', 'route': '/athlete/my-coach'},
          },
          {
            'type': 'spacer',
            'props': {'height': 24},
          },
          {
            'type': 'list',
            'id': 'upcoming-assignments',
            'props': {
              'title': 'Ближайшие задания',
              'empty_text': 'Нет запланированных заданий',
              'divider': true,
            },
            'children': [
              {
                'type': 'list_tile',
                'props': {
                  'title': 'Развивающий кросс 5 км',
                  'subtitle': 'Завтра',
                  'leading_icon': 'directions_run',
                },
              },
              {
                'type': 'list_tile',
                'props': {
                  'title': 'ОФП: круговая тренировка',
                  'subtitle': 'Через 2 дня',
                  'leading_icon': 'fitness_center',
                },
              },
            ],
          },
          {
            'type': 'spacer',
            'props': {'height': 16},
          },
          {
            'type': 'button',
            'props': {
              'text': 'Все задания',
              'style': 'outlined',
              'icon': 'arrow_forward',
              'full_width': true,
            },
            'action': {
              'type': 'navigate',
              'route': '/athlete/assignments',
            },
          },
        ],
      },
    });
  }
}
