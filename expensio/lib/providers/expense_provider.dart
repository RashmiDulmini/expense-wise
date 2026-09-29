import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/expense_model.dart';
import '../services/firebase_service.dart';

enum ExpenseFilter { all, thisMonth, lastMonth, thisWeek }

enum SortOrder { dateDesc, dateAsc, amountDesc, amountAsc }

class ExpenseProvider extends ChangeNotifier {
  final FirebaseService _service = FirebaseService();
  final _uuid = const Uuid();

  List<Expense> _allExpenses = [];
  bool _isLoading = false;
  String? _error;
  User? _currentUser;

  ExpenseCategory? _selectedCategory;
  ExpenseFilter _filter = ExpenseFilter.thisMonth;
  SortOrder _sortOrder = SortOrder.dateDesc;
  String _searchQuery = '';
  DateTimeRange? _customDateRange;

  // ─── Getters ─────────────────────────────────────────────────────────────────

  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get currentUser => _currentUser;
  ExpenseCategory? get selectedCategory => _selectedCategory;
  ExpenseFilter get filter => _filter;
  SortOrder get sortOrder => _sortOrder;
  String get searchQuery => _searchQuery;
  DateTimeRange? get customDateRange => _customDateRange;
  bool get isSignedIn => _currentUser != null;

  List<Expense> get filteredExpenses {
    List<Expense> expenses = List.from(_allExpenses);

    // Search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      expenses =
          expenses
              .where(
                (e) =>
                    e.title.toLowerCase().contains(q) ||
                    e.category.label.toLowerCase().contains(q) ||
                    (e.note?.toLowerCase().contains(q) ?? false),
              )
              .toList();
    }

    // Category filter
    if (_selectedCategory != null) {
      expenses =
          expenses.where((e) => e.category == _selectedCategory).toList();
    }

    // Date filter
    final now = DateTime.now();
    switch (_filter) {
      case ExpenseFilter.thisMonth:
        expenses =
            expenses
                .where(
                  (e) => e.date.year == now.year && e.date.month == now.month,
                )
                .toList();
        break;
      case ExpenseFilter.lastMonth:
        final lastMonth = DateTime(now.year, now.month - 1);
        expenses =
            expenses
                .where(
                  (e) =>
                      e.date.year == lastMonth.year &&
                      e.date.month == lastMonth.month,
                )
                .toList();
        break;
      case ExpenseFilter.thisWeek:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekStartDay = DateTime(
          weekStart.year,
          weekStart.month,
          weekStart.day,
        );
        expenses =
            expenses.where((e) => e.date.isAfter(weekStartDay)).toList();
        break;
      case ExpenseFilter.all:
        if (_customDateRange != null) {
          expenses =
              expenses
                  .where(
                    (e) =>
                        e.date.isAfter(
                          _customDateRange!.start.subtract(
                            const Duration(days: 1),
                          ),
                        ) &&
                        e.date.isBefore(
                          _customDateRange!.end.add(const Duration(days: 1)),
                        ),
                  )
                  .toList();
        }
        break;
    }

    // Sort
    switch (_sortOrder) {
      case SortOrder.dateDesc:
        expenses.sort((a, b) => b.date.compareTo(a.date));
        break;
      case SortOrder.dateAsc:
        expenses.sort((a, b) => a.date.compareTo(b.date));
        break;
      case SortOrder.amountDesc:
        expenses.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case SortOrder.amountAsc:
        expenses.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }

    return expenses;
  }

  double get totalFilteredAmount =>
      filteredExpenses.fold(0, (sum, e) => sum + e.amount);

  double get thisMonthTotal {
    final now = DateTime.now();
    return _allExpenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0, (sum, e) => sum + e.amount);
  }

  Map<ExpenseCategory, double> get categoryTotals {
    final Map<ExpenseCategory, double> totals = {};
    for (final expense in filteredExpenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }

  Map<String, double> get weeklyTotals {
    final Map<String, double> totals = {};
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final key =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      totals[key] = 0;
    }
    for (final expense in _allExpenses) {
      final key =
          '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}-${expense.date.day.toString().padLeft(2, '0')}';
      if (totals.containsKey(key)) {
        totals[key] = (totals[key] ?? 0) + expense.amount;
      }
    }
    return totals;
  }

  // ─── Auth ─────────────────────────────────────────────────────────────────

  Future<void> initializeAuth() async {
    _service.authStateChanges.listen((user) {
      _currentUser = user;
      if (user != null) {
        _listenToExpenses(user.uid);
      } else {
        _allExpenses = [];
      }
      notifyListeners();
    });
  }

  Future<void> signInAnonymously() async {
    _setLoading(true);
    try {
      await _service.signInAnonymously();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      await _service.signInWithEmailAndPassword(email, password);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_friendlyAuthError(e.code));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> registerWithEmail(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      await _service.createUserWithEmailAndPassword(email, password);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_friendlyAuthError(e.code));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _service.signOut();
    _allExpenses = [];
    notifyListeners();
  }

  String _friendlyAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  // ─── Expense Operations ───────────────────────────────────────────────────

  void _listenToExpenses(String userId) {
    _service.getExpensesStream(userId).listen(
      (expenses) {
        _allExpenses = expenses;
        _clearError();
        notifyListeners();
      },
      onError: (e) {
        _setError('Failed to load expenses: ${e.toString()}');
      },
    );
  }

  Future<bool> addExpense({
    required String title,
    required double amount,
    required ExpenseCategory category,
    required DateTime date,
    String? note,
  }) async {
    if (_currentUser == null) return false;
    _setLoading(true);
    try {
      final expense = Expense(
        id: _uuid.v4(),
        title: title,
        amount: amount,
        category: category,
        date: date,
        note: note,
        userId: _currentUser!.uid,
        createdAt: DateTime.now(),
      );
      await _service.addExpense(expense);
      return true;
    } catch (e) {
      _setError('Failed to add expense: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateExpense(Expense expense) async {
    _setLoading(true);
    try {
      await _service.updateExpense(expense);
      return true;
    } catch (e) {
      _setError('Failed to update expense: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteExpense(String expenseId) async {
    if (_currentUser == null) return false;
    try {
      await _service.deleteExpense(_currentUser!.uid, expenseId);
      return true;
    } catch (e) {
      _setError('Failed to delete expense: ${e.toString()}');
      return false;
    }
  }

  // ─── Filters ──────────────────────────────────────────────────────────────

  void setCategory(ExpenseCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setFilter(ExpenseFilter filter) {
    _filter = filter;
    _customDateRange = null;
    notifyListeners();
  }

  void setSortOrder(SortOrder order) {
    _sortOrder = order;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCustomDateRange(DateTimeRange? range) {
    _customDateRange = range;
    _filter = ExpenseFilter.all;
    notifyListeners();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
