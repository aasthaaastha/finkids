import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key, required this.moduleId});
  final String moduleId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(moduleId[0].toUpperCase() + moduleId.substring(1))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lesson content coming soon',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(
              'Module: $moduleId',
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => context.push('/learn/quiz/$moduleId'),
                child: const Text('Take quiz'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
