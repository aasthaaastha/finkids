import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'module.freezed.dart';
part 'module.g.dart';

// ─────────────────────────────────────────────
// Run after any model change:
// dart run build_runner build --delete-conflicting-outputs
// ─────────────────────────────────────────────

@freezed
class LearningModule with _$LearningModule {
  // Private constructor enables custom getters below.
  const LearningModule._();

  const factory LearningModule({
    required String id,
    required String title,
    required String subtitle,
    required String iconName,
    required String colorHex, // e.g. "534AB7" — no leading #
    required List<Lesson> lessons,
    required ModuleQuiz quiz,
  }) = _LearningModule;

  factory LearningModule.fromJson(Map<String, dynamic> json) =>
      _$LearningModuleFromJson(json);

  /// Primary color parsed from the hex string in JSON.
  Color get color => Color(int.parse('FF$colorHex', radix: 16));

  /// A soft 12% opacity version for backgrounds and badges.
  Color get lightColor => color.withOpacity(0.12);

  /// Maps the iconName string from JSON to a Flutter IconData.
  IconData get icon {
    switch (iconName) {
      case 'savings':
        return Icons.savings_rounded;
      case 'trending_up':
        return Icons.trending_up_rounded;
      case 'show_chart':
        return Icons.show_chart_rounded;
      case 'pie_chart':
        return Icons.pie_chart_rounded;
      case 'school':
        return Icons.school_rounded;
      default:
        return Icons.book_rounded;
    }
  }
}

@freezed
class Lesson with _$Lesson {
  const factory Lesson({
    required String id,
    required String title,
    required String duration,
    required String content,
    required List<String> keyPoints,
  }) = _Lesson;

  factory Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);
}

@freezed
class ModuleQuiz with _$ModuleQuiz {
  const factory ModuleQuiz({
    required List<Question> questions,
  }) = _ModuleQuiz;

  factory ModuleQuiz.fromJson(Map<String, dynamic> json) =>
      _$ModuleQuizFromJson(json);
}

@freezed
class Question with _$Question {
  const factory Question({
    required String id,
    required String question,
    required List<String> options,
    required int correctIndex,
    required String explanation,
  }) = _Question;

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);
}
