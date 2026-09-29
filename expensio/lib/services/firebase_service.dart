import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/expense_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─── Auth ───────────────────────────────────────────────────────────────────

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInAnonymously() async {
    return await _auth.signInAnonymously();
  }

  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ─── Expenses ────────────────────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> _expensesCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('expenses');
  }

  Stream<List<Expense>> getExpensesStream(String userId) {
    return _expensesCollection(userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList(),
        );
  }

  Future<void> addExpense(Expense expense) async {
    await _expensesCollection(
      expense.userId,
    ).doc(expense.id).set(expense.toFirestore());
  }

  Future<void> updateExpense(Expense expense) async {
    await _expensesCollection(
      expense.userId,
    ).doc(expense.id).update(expense.toFirestore());
  }

  Future<void> deleteExpense(String userId, String expenseId) async {
    await _expensesCollection(userId).doc(expenseId).delete();
  }
}
