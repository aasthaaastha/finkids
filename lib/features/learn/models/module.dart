import 'package:flutter/material.dart';

// Plain Dart models — no code generation needed.
// Same API as the Freezed version so no other files need changing.

class LearningModule {
  const LearningModule({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.colorHex,
    required this.lessons,
    required this.quiz,
  });

  final String id;
  final String title;
  final String subtitle;
  final String iconName;
  final String colorHex; // e.g. "534AB7" — no leading #
  final List<Lesson> lessons;
  final ModuleQuiz quiz;

  // ── Computed UI helpers ───────────────────────

  Color get color => Color(int.parse('FF$colorHex', radix: 16));
  Color get lightColor => color.withOpacity(0.12);

  IconData get icon {
    switch (iconName) {
      case 'savings':       return Icons.savings_rounded;
      case 'trending_up':   return Icons.trending_up_rounded;
      case 'show_chart':    return Icons.show_chart_rounded;
      case 'pie_chart':     return Icons.pie_chart_rounded;
      case 'school':        return Icons.school_rounded;
      default:              return Icons.book_rounded;
    }
  }

  // ── JSON ─────────────────────────────────────

  factory LearningModule.fromJson(Map<String, dynamic> json) {
    return LearningModule(
      id:        json['id'] as String,
      title:     json['title'] as String,
      subtitle:  json['subtitle'] as String,
      iconName:  json['iconName'] as String,
      colorHex:  json['colorHex'] as String,
      lessons:   (json['lessons'] as List<dynamic>)
                     .map((l) => Lesson.fromJson(l as Map<String, dynamic>))
                     .toList(),
      quiz:      ModuleQuiz.fromJson(json['quiz'] as Map<String, dynamic>),
    );
  }
}

class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.duration,
    required this.content,
    required this.keyPoints,
  });

  final String id;
  final String title;
  final String duration;
  final String content;
  final List<String> keyPoints;

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id:        json['id'] as String,
      title:     json['title'] as String,
      duration:  json['duration'] as String,
      content:   json['content'] as String,
      keyPoints: List<String>.from(json['keyPoints'] as List),
    );
  }
}

class ModuleQuiz {
  const ModuleQuiz({required this.questions});

  final List<Question> questions;

  factory ModuleQuiz.fromJson(Map<String, dynamic> json) {
    return ModuleQuiz(
      questions: (json['questions'] as List<dynamic>)
          .map((q) => Question.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Question {
  const Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id:           json['id'] as String,
      question:     json['question'] as String,
      options:      List<String>.from(json['options'] as List),
      correctIndex: json['correctIndex'] as int,
      explanation:  json['explanation'] as String,
    );
  }
}
