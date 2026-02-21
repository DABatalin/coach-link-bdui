import '../domain/ai_repository.dart';
import '../domain/models/ai_result.dart';

class AiRepositoryMock implements AiRepository {
  static const _model = 'gemma3:4b';

  static const _recommendationsText =
      'На основе данных за последний месяц рекомендую:\n\n'
      '1. Постепенно увеличить недельный объём бега на 10% — текущие показатели '
      'говорят о хорошей адаптации к нагрузке.\n\n'
      '2. Добавить одну восстановительную тренировку в неделю с пульсом '
      'не выше 135 уд/мин — средний пульс немного высок (152 уд/мин).\n\n'
      '3. Обратить внимание на самочувствие в четвёртую неделю: RPE 6.8 '
      'при росте объёма — признак накапливающейся усталости. '
      'Рекомендую снизить интенсивность на следующей неделе.\n\n'
      '4. Процент выполнения заданий (82%) хороший, но есть резерв. '
      'Проанализируйте причины невыполненных тренировок — возможно, '
      'слишком сложное расписание.';

  static const _analysisText =
      'Анализ тренировочного процесса за последний месяц:\n\n'
      '📈 Тенденции:\n'
      '— Объём нагрузки стабильно растёт (+12% к третьей неделе).\n'
      '— Средний пульс увеличился с 145 до 158 уд/мин, что коррелирует '
      'с ростом интенсивности.\n'
      '— RPE также растёт (5.8 → 6.8), что соответствует прогрессии нагрузки.\n\n'
      '⚠️ Зоны внимания:\n'
      '— Четвёртая неделя показывает признаки перегрузки: высокий RPE '
      'при максимальном объёме. Рекомендуется разгрузочная неделя.\n'
      '— Дистанция растёт быстрее, чем рекомендуется (>10% в неделю) — '
      'риск травмы при продолжении такой прогрессии.\n\n'
      '✅ Положительные моменты:\n'
      '— Высокий процент выполнения заданий (82%).\n'
      '— Спортсмен справляется с нагрузкой без жалоб на самочувствие.';

  static const _summaryText =
      'Сводка по команде за последние 7 дней:\n\n'
      '👥 3 активных спортсмена, выполнено 14 тренировок.\n\n'
      '📊 Общие тенденции:\n'
      '— Сидорова М. показывает наилучший процент выполнения (91%) и '
      'стабильный RPE. Нагрузку можно увеличивать.\n'
      '— Петров И. на правильном пути, но четвёртая неделя вызывает '
      'вопросы по накопленной усталости.\n'
      '— Козлов Д. требует особого внимания: процент выполнения 62%, '
      'самый высокий RPE (7.1) — возможны проблемы с мотивацией '
      'или слишком высокая для него нагрузка.\n\n'
      '💡 Рекомендации:\n'
      '— Провести индивидуальную беседу с Козловым — выяснить причины '
      'невыполнения заданий.\n'
      '— Для Сидоровой можно запланировать соревновательную тренировку '
      'или контрольный старт.\n'
      '— Петрову запланировать разгрузочную неделю.';

  @override
  Future<AiResult> getAthleteRecommendations({
    required String athleteId,
    String? context,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    return AiResult(
      athleteId: athleteId,
      type: 'recommendations',
      content: _recommendationsText,
      generatedAt: DateTime.now(),
      model: _model,
    );
  }

  @override
  Future<AiResult> getAthleteAnalysis({
    required String athleteId,
    String? context,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    return AiResult(
      athleteId: athleteId,
      type: 'analysis',
      content: _analysisText,
      generatedAt: DateTime.now(),
      model: _model,
    );
  }

  @override
  Future<AiResult> getCoachSummary({
    DateTime? dateFrom,
    DateTime? dateTo,
    String? context,
  }) async {
    await Future.delayed(const Duration(seconds: 3));
    return AiResult(
      type: 'summary',
      content: _summaryText,
      generatedAt: DateTime.now(),
      model: _model,
    );
  }
}
