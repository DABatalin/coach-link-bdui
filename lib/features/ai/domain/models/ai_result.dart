class AiResult {
  const AiResult({
    this.athleteId,
    required this.type,
    required this.content,
    required this.generatedAt,
    required this.model,
  });

  final String? athleteId;
  final String type;
  final String content;
  final DateTime generatedAt;
  final String model;

  factory AiResult.fromJson(Map<String, dynamic> json) => AiResult(
        athleteId: json['athlete_id'] as String?,
        type: json['type'] as String,
        content: json['content'] as String,
        generatedAt: DateTime.parse(json['generated_at'] as String),
        model: json['model'] as String,
      );
}
