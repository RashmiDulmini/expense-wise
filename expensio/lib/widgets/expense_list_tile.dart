import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense_model.dart';
import '../providers/expense_provider.dart';
import '../theme/app_theme.dart';
import '../screens/add_edit_expense_screen.dart';

class ExpenseListTile extends StatelessWidget {
  final Expense expense;
  final int index;

  const ExpenseListTile({super.key, required this.expense, required this.index});

  void _showOptions(BuildContext context) {
    // Capture root navigator context before bottom sheet opens
    final rootContext = context;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _ExpenseOptions(expense: expense, rootContext: rootContext),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color =
        AppTheme.categoryColors[expense.category.name] ?? AppTheme.textSecondary;
    final formattedDate = DateFormat('MMM d').format(expense.date);
    final formattedAmount = AppTheme.formatCurrency(expense.amount);

    return GestureDetector(
      onTap: () => _showOptions(context),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            // Category Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  expense.category.icon,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Title & Category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          expense.category.label,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                      if (expense.note != null && expense.note!.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.notes_rounded,
                          size: 12,
                          color: AppTheme.textMuted,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Amount & Date
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    formattedAmount,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  formattedDate,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Expense Options Bottom Sheet ─────────────────────────────────────────────

class _ExpenseOptions extends StatelessWidget {
  final Expense expense;
  final BuildContext rootContext;

  const _ExpenseOptions({required this.expense, required this.rootContext});

  @override
  Widget build(BuildContext context) {
    final color =
        AppTheme.categoryColors[expense.category.name] ?? AppTheme.textSecondary;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Expense summary header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    expense.category.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '${AppTheme.formatCurrency(expense.amount)} · ${expense.category.label}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (expense.note != null && expense.note!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border),
              ),
              child: Text(
                expense.note!,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),
          const Divider(color: AppTheme.border),
          const SizedBox(height: 8),

          // Actions
          ListTile(
            leading: const Icon(
              Icons.edit_outlined,
              color: AppTheme.primary,
            ),
            title: Text(
              'Edit Expense',
              style: GoogleFonts.inter(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditExpenseScreen(expense: expense),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(
              Icons.delete_outline_rounded,
              color: AppTheme.error,
            ),
            title: Text(
              'Delete Expense',
              style: GoogleFonts.inter(
                color: AppTheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              // Use rootContext so dialog has a valid mounted context
              Future.microtask(() => _confirmDelete(rootContext));
            },
          ),
          ],
        ),
      ),
    ),
  ),
);
}

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _DeleteConfirmDialog(expense: expense),
    );
  }
}

// ─── Delete Confirm Dialog ─────────────────────────────────────────────────────

class _DeleteConfirmDialog extends StatefulWidget {
  final Expense expense;
  const _DeleteConfirmDialog({required this.expense});

  @override
  State<_DeleteConfirmDialog> createState() => _DeleteConfirmDialogState();
}

class _DeleteConfirmDialogState extends State<_DeleteConfirmDialog> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppTheme.border),
      ),
      title: Text(
        'Delete Expense',
        style: GoogleFonts.inter(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      content: Text(
        'Are you sure you want to delete "${widget.expense.title}"? This cannot be undone.',
        style: GoogleFonts.inter(
          color: AppTheme.textSecondary,
          fontSize: 14,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.inter(color: AppTheme.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: _isDeleting ? null : _handleDelete,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.error,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: _isDeleting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Delete',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _handleDelete() async {
    setState(() => _isDeleting = true);

    final provider = context.read<ExpenseProvider>();
    final success = await provider.deleteExpense(widget.expense.id);

    if (!mounted) return;

    // Close the confirm dialog
    Navigator.of(context).pop();

    if (success) {
      // Show centered success popup overlay
      _showDeleteSuccessOverlay(context);
    }
  }
}

void _showDeleteSuccessOverlay(BuildContext context) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => _DeleteSuccessPopup(
      onDismiss: () => entry.remove(),
    ),
  );

  overlay.insert(entry);

  // Auto dismiss after 1.8 seconds
  Future.delayed(const Duration(milliseconds: 1800), () {
    if (entry.mounted) entry.remove();
  });
}

// ─── Centered success popup ────────────────────────────────────────────────────

class _DeleteSuccessPopup extends StatefulWidget {
  final VoidCallback onDismiss;
  const _DeleteSuccessPopup({required this.onDismiss});

  @override
  State<_DeleteSuccessPopup> createState() => _DeleteSuccessPopupState();
}

class _DeleteSuccessPopupState extends State<_DeleteSuccessPopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();

    // Start fade-out before removal
    Future.delayed(const Duration(milliseconds: 1300), () {
      if (mounted) _ctrl.reverse();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Center(
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 28,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF22C55E),
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Expense Deleted',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Successfully removed',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
