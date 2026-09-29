import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  final VoidCallback onAddTap;

  const EmptyState({super.key, required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '💸',
            style: const TextStyle(fontSize: 72),
          ).animate(
            onPlay: (controller) => controller.repeat(reverse: true),
          ).moveY(
            begin: 0,
            end: -12,
            duration: 1500.ms,
            curve: Curves.easeInOut,
          ),

          const SizedBox(height: 24),

          Text(
            'No expenses yet',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 8),

          Text(
            'Start tracking your spending\nby adding your first expense.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 32),

          ElevatedButton.icon(
            onPressed: onAddTap,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text(
              'Add First Expense',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.9, 0.9)),
        ],
      ),
    );
  }
}
