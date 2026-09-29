import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/expense_model.dart';
import '../theme/app_theme.dart';

class CategoryFilterBar extends StatelessWidget {
  final ExpenseCategory? selectedCategory;
  final ValueChanged<ExpenseCategory?> onCategorySelected;

  const CategoryFilterBar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // "All" chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _FilterChip(
              label: 'All',
              isSelected: selectedCategory == null,
              onTap: () => onCategorySelected(null),
              color: AppTheme.primary,
            ),
          ),
          // Category chips
          ...ExpenseCategory.values.map((category) {
            final color =
                AppTheme.categoryColors[category.name] ??
                AppTheme.textSecondary;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: category.label.split(' ').first,
                emoji: category.icon,
                isSelected: selectedCategory == category,
                onTap: () => onCategorySelected(
                  selectedCategory == category ? null : category,
                ),
                color: color,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String? emoji;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _FilterChip({
    required this.label,
    this.emoji,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? color : AppTheme.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null && emoji!.isNotEmpty) ...[
              Text(emoji!, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
