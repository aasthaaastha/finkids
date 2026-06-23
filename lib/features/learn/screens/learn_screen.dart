import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/module.dart';
import '../models/module_progress.dart';
import '../providers/modules_provider.dart';
import '../providers/progress_provider.dart';

class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modulesAsync = ref.watch(modulesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
      body: modulesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Could not load modules: $e'),
        ),
        data: (modules) => ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: modules.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final module = modules[i];
            final progress = ref.watch(moduleProgressProvider(module.id));
            return _ModuleCard(
              module: module,
              progress: progress,
              onTap: () => context.push('/learn/lesson/${module.id}'),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Module card with progress ring
// ─────────────────────────────────────────────

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.module,
    required this.progress,
    required this.onTap,
  });

  final LearningModule module;
  final ModuleProgressData progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ratio = progress.lessonRatio(module.lessons.length);
    final isDone = progress.quizPassed;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon with soft background
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: module.lightColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(module.icon, color: module.color, size: 26),
              ),
              const SizedBox(width: 14),

              // Title + subtitle + lesson count
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            module.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isDone)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    size: 12, color: Colors.green.shade700),
                                const SizedBox(width: 3),
                                Text(
                                  'Done',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      module.subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: isDone ? 1.0 : ratio,
                        minHeight: 5,
                        backgroundColor: module.lightColor,
                        valueColor:
                            AlwaysStoppedAnimation(module.color),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isDone
                          ? 'Completed · ${module.lessons.length} lessons · score ${progress.scoreLabel}'
                          : '${progress.completedLessonIds.length}/${module.lessons.length} lessons',
                      style: TextStyle(
                        fontSize: 11,
                        color: module.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
