import 'package:expense_app/main.dart';
import 'package:expense_app/models/expense.dart';
import 'package:flutter/material.dart';

class ExpensesItem extends StatelessWidget {
  const ExpensesItem(this.expense, {super.key});

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    final color = expense.isIncome ? kIncomeColor : kExpenseColor;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Color indicator bar
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 14),
            // Category icon circle
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CategoryIcons[expense.category],
                size: 18,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            // Title and date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    expense.formattedDate,
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
            // Amount with +/-
            Text(
              '${expense.isIncome ? '+' : '-'}\$${expense.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
