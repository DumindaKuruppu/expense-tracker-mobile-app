import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final String title;
  final String content;

  const ConfirmDeleteDialog({
    super.key,
    this.title = 'Delete Expense',
    this.content = 'Are you sure you want to delete this expense record? This action cannot be undone.',
  });

  static Future<bool?> show(BuildContext context, {String? title, String? content}) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDeleteDialog(
        title: title ?? 'Delete Expense',
        content: content ?? 'Are you sure you want to delete this expense record? This action cannot be undone.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.expense.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.delete_outline, color: AppColors.expense),
          ),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
      content: Text(
        content,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.expense,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
