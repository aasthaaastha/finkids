import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/module.dart';
import '../providers/modules_provider.dart';
import '../providers/progress_provider.dart';

class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({super.key, required this.moduleId});
  final String moduleId;

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  int _lessonIndex = 0;

  @override
  Widget build(BuildContext context) {
    final moduleAsync = ref.watch(moduleByIdProvider(widget.moduleId));
    return moduleAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (module) {
        if (module == null) return const Scaffold(body: Center(child: Text('Module not found')));
        return _LessonView(
          module: module,
          lessonIndex: _lessonIndex,
          onLessonCompleted: (id) =>
              ref.read(progressProvider.notifier).completeLesson(widget.moduleId, id),
          onNextLesson: () => setState(() => _lessonIndex++),
          onGoToQuiz: () => context.push('/learn/quiz/${widget.moduleId}'),
        );
      },
    );
  }
}

class _LessonView extends ConsumerWidget {
  const _LessonView({
    required this.module,
    required this.lessonIndex,
    required this.onLessonCompleted,
    required this.onNextLesson,
    required this.onGoToQuiz,
  });

  final LearningModule module;
  final int lessonIndex;
  final void Function(String lessonId) onLessonCompleted;
  final VoidCallback onNextLesson;
  final VoidCallback onGoToQuiz;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lesson = module.lessons[lessonIndex];
    final isLastLesson = lessonIndex == module.lessons.length - 1;
    final progress = ref.watch(moduleProgressProvider(module.id));
    final isAlreadyComplete = progress.isLessonCompleted(lesson.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(module.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (lessonIndex + 1) / module.lessons.length,
            minHeight: 4,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(module.color),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Chip(
                  label: 'Lesson ${lessonIndex + 1} of ${module.lessons.length}',
                  color: module.color,
                  bgColor: module.lightColor,
                ),
                const Spacer(),
                _Chip(
                  label: lesson.duration,
                  icon: Icons.timer_outlined,
                  color: Colors.grey.shade600,
                  bgColor: Colors.grey.shade100,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(lesson.title,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, height: 1.2)),
            const SizedBox(height: 20),
            ...lesson.content.split('\n\n').map(
                  (para) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(para.trim(),
                        style: const TextStyle(
                            fontSize: 16, height: 1.75, color: Color(0xFF374151))),
                  ),
                ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: module.lightColor, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Key points',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600, color: module.color)),
                  const SizedBox(height: 14),
                  ...lesson.keyPoints.map(
                    (point) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle_rounded, size: 18, color: module.color),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(point,
                                style: TextStyle(
                                    fontSize: 14,
                                    height: 1.5,
                                    color: module.color.withOpacity(0.85))),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: module.color, foregroundColor: Colors.white),
              onPressed: () {
                if (!isAlreadyComplete) onLessonCompleted(lesson.id);
                if (isLastLesson) {
                  onGoToQuiz();
                } else {
                  onNextLesson();
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLastLesson
                        ? (isAlreadyComplete ? 'Take the quiz' : 'Complete & take quiz')
                        : (isAlreadyComplete ? 'Next lesson' : 'Complete & next lesson'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color, required this.bgColor, this.icon});
  final String label;
  final Color color;
  final Color bgColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 13, color: color), const SizedBox(width: 4)],
          Text(label,
              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
