import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/module_progress.dart';

const _kBoxName = 'moduleProgress';

/// Provides the already-opened Hive box.
/// Make sure Hive.openBox(_kBoxName) is called in main() before this runs.
final progressBoxProvider = Provider<Box>(
  (ref) => Hive.box(_kBoxName),
  // Box is opened in main.dart — never close it while the app is running.
);

/// The full progress map: moduleId → ModuleProgressData.
final progressProvider = StateNotifierProvider<ProgressNotifier,
    Map<String, ModuleProgressData>>(
  (ref) {
    final box = ref.watch(progressBoxProvider);
    return ProgressNotifier(box);
  },
);

/// Convenience: progress for a single module (empty if not started).
final moduleProgressProvider =
    Provider.family<ModuleProgressData, String>((ref, moduleId) {
  return ref.watch(progressProvider)[moduleId] ??
      ModuleProgressData.empty(moduleId);
});

// ─────────────────────────────────────────────
// StateNotifier
// ─────────────────────────────────────────────

class ProgressNotifier
    extends StateNotifier<Map<String, ModuleProgressData>> {
  final Box _box;

  ProgressNotifier(this._box) : super(_loadAll(_box));

  // ── Load ──────────────────────────────────

  static Map<String, ModuleProgressData> _loadAll(Box box) {
    final result = <String, ModuleProgressData>{};
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw is Map) {
        try {
          result[key as String] =
              ModuleProgressData.fromMap(Map<String, dynamic>.from(raw));
        } catch (_) {
          // Corrupted entry — skip silently
        }
      }
    }
    return result;
  }

  // ── Mutations ─────────────────────────────

  /// Marks a lesson as complete. Idempotent — safe to call multiple times.
  void completeLesson(String moduleId, String lessonId) {
    final current =
        state[moduleId] ?? ModuleProgressData.empty(moduleId);
    if (current.isLessonCompleted(lessonId)) return;

    final updated = current.copyWith(
      completedLessonIds: [...current.completedLessonIds, lessonId],
    );
    _persist(moduleId, updated);
  }

  /// Saves the quiz result. 75% or above is considered a pass.
  void saveQuizResult(String moduleId, int score, int total) {
    final current =
        state[moduleId] ?? ModuleProgressData.empty(moduleId);
    final passed = total > 0 && (score / total) >= 0.75;
    final updated = current.copyWith(
      quizScore: score,
      quizTotal: total,
      quizPassed: passed,
    );
    _persist(moduleId, updated);
  }

  /// Resets all progress for a module (useful for retrying from scratch).
  void resetModule(String moduleId) {
    _box.delete(moduleId);
    state = {...state}..remove(moduleId);
  }

  void _persist(String moduleId, ModuleProgressData data) {
    _box.put(moduleId, data.toMap());
    state = {...state, moduleId: data};
  }
}
