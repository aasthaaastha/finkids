import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      // FAB navigates to the Add Expense modal (renders above the shell)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/expenses/add'),
        backgroundColor: AppColors.expenses,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add expense',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_rounded,
                size: 64, color: AppColors.expensesLight),
            SizedBox(height: 16),
            Text('No expenses yet',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary)),
            SizedBox(height: 8),
            Text('Tap + to log your first expense',
                style:
                    TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
