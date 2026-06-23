/// Tracks a user's progress through a single learning module.
/// Stored in Hive as a plain Map so no adapter code-gen is needed.
class ModuleProgressData {
  final String moduleId;
  final List<String> completedLessonIds;
  final int? quizScore;
  final int? quizTotal;
  final bool quizPassed;

  const ModuleProgressData({
    required this.moduleId,
    required this.completedLessonIds,
    this.quizScore,
    this.quizTotal,
    this.quizPassed = false,
  });

  // ── Convenience getters ──────────────────────

  /// 0.0 → 1.0 based on how many lessons are done vs total.
  double lessonRatio(int totalLessons) =>
      totalLessons == 0 ? 0 : completedLessonIds.length / totalLessons;

  bool isLessonCompleted(String lessonId) =>
      completedLessonIds.contains(lessonId);

  bool get allLessonsCompleted =>
      completedLessonIds.isNotEmpty; // caller checks vs module.lessons.length

  String? get scoreLabel =>
      (quizScore != null && quizTotal != null) ? '$quizScore/$quizTotal' : null;

  // ── Factory ──────────────────────────────────

  factory ModuleProgressData.empty(String moduleId) => ModuleProgressData(
        moduleId: moduleId,
        completedLessonIds: const [],
      );

  // ── Mutation ─────────────────────────────────

  ModuleProgressData copyWith({
    List<String>? completedLessonIds,
    int? quizScore,
    int? quizTotal,
    bool? quizPassed,
  }) =>
      ModuleProgressData(
        moduleId: moduleId,
        completedLessonIds: completedLessonIds ?? this.completedLessonIds,
        quizScore: quizScore ?? this.quizScore,
        quizTotal: quizTotal ?? this.quizTotal,
        quizPassed: quizPassed ?? this.quizPassed,
      );

  // ── Hive serialisation ───────────────────────

  Map<String, dynamic> toMap() => {
        'moduleId': moduleId,
        'completedLessonIds': completedLessonIds,
        'quizScore': quizScore,
        'quizTotal': quizTotal,
        'quizPassed': quizPassed,
      };

  factory ModuleProgressData.fromMap(Map<String, dynamic> map) =>
      ModuleProgressData(
        moduleId: map['moduleId'] as String,
        completedLessonIds:
            List<String>.from(map['completedLessonIds'] as List? ?? []),
        quizScore: map['quizScore'] as int?,
        quizTotal: map['quizTotal'] as int?,
        quizPassed: map['quizPassed'] as bool? ?? false,
      );
}
