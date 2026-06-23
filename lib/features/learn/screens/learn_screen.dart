import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

/// A simple data class for a learning module.
/// Later you'll move this to a proper model + Hive/JSON.
class _Module {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final int totalLessons;

  const _Module({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.totalLessons,
  });
}

const _modules = [
  _Module(
    id: 'savings',
    title: 'What is saving?',
    subtitle: 'Why keeping money matters',
    icon: Icons.savings_rounded,
    color: AppColors.learn,
    bgColor: AppColors.learnLight,
    totalLessons: 4,
  ),
  _Module(
    id: 'stocks',
    title: 'How stocks work',
    subtitle: 'Owning a piece of a company',
    icon: Icons.show_chart_rounded,
    color: AppColors.home,
    bgColor: AppColors.homeLight,
    totalLessons: 5,
  ),
  _Module(
    id: 'compound',
    title: 'Compound interest',
    subtitle: 'Making your money grow',
    icon: Icons.trending_up_rounded,
    color: AppColors.expenses,
    bgColor: AppColors.expensesLight,
    totalLessons: 3,
  ),
  _Module(
    id: 'budget',
    title: 'Making a budget',
    subtitle: 'Spend smart, save more',
    icon: Icons.pie_chart_rounded,
    color: AppColors.location,
    bgColor: AppColors.locationLight,
    totalLessons: 3,
  ),
];

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _modules.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final m = _modules[index];
          return _ModuleCard(module: m);
        },
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.module});
  final _Module module;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/learn/lesson/${module.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon circle
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: module.bgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(module.icon, color: module.color, size: 26),
              ),
              const SizedBox(width: 14),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      module.subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${module.totalLessons} lessons',
                      style: TextStyle(
                        fontSize: 12,
                        color: module.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
