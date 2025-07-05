// providers/transaction_provider.dart
import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';

class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  List<Transaction> _filteredTransactions = [];
  
  List<Transaction> get transactions => _transactions;
  List<Transaction> get filteredTransactions => _filteredTransactions;

  double get totalIncome {
    return _transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpenses {
    return _transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get balance => totalIncome - totalExpenses;

  Future<void> loadTransactions(String userId) async {
    _transactions = await DatabaseService.instance.getTransactionsByUserId(userId);
    _filteredTransactions = _transactions;
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await DatabaseService.instance.insertTransaction(transaction);
    _transactions.insert(0, transaction);
    _filteredTransactions = _transactions;
    notifyListeners();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await DatabaseService.instance.updateTransaction(transaction);
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
      _filteredTransactions = _transactions;
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String id) async {
    await DatabaseService.instance.deleteTransaction(id);
    _transactions.removeWhere((t) => t.id == id);
    _filteredTransactions = _transactions;
    notifyListeners();
  }

  Future<void> filterTransactions(
    String userId, {
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    String? type,
  }) async {
    _filteredTransactions = await DatabaseService.instance.getFilteredTransactions(
      userId,
      category: category,
      startDate: startDate,
      endDate: endDate,
      type: type,
    );
    notifyListeners();
  }

  void clearFilters() {
    _filteredTransactions = _transactions;
    notifyListeners();
  }

  List<String> get categories => [
    'Food & Dining',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Bills & Utilities',
    'Healthcare',
    'Education',
    'Travel',
    'Salary',
    'Investment',
    'Gift',
    'Other',
  ];
}

// // providers/transaction_provider.dart
// import 'package:flutter/foundation.dart';
// import '../models/transaction.dart';
// import '../services/database_service.dart';

// class TransactionProvider extends ChangeNotifier {
//   List<Transaction> _transactions = [];
//   List<Transaction> _filteredTransactions = [];
  
//   List<Transaction> get transactions => _transactions;
//   List<Transaction> get filteredTransactions => _filteredTransactions;

//   double get totalIncome {
//     return _transactions
//         .where((t) => t.type == 'income')
//         .fold(0.0, (sum, t) => sum + t.amount);
//   }

//   double get totalExpenses {
//     return _transactions
//         .where((t) => t.type == 'expense')
//         .fold(0.0, (sum, t) => sum + t.amount);
//   }

//   double get balance => totalIncome - totalExpenses;

//   Future<void> loadTransactions(String userId) async {
//     _transactions = await DatabaseService.instance.getTransactionsByUserId(userId);
//     _filteredTransactions = _transactions;
//     notifyListeners();
//   }

//   Future<void> addTransaction(Transaction transaction) async {
//     await DatabaseService.instance.insertTransaction(transaction);
//     _transactions.insert(0, transaction);
//     _filteredTransactions = _transactions;
//     notifyListeners();
//   }

//   Future<void> updateTransaction(Transaction transaction) async {
//     await DatabaseService.instance.updateTransaction(transaction);
//     final index = _transactions.indexWhere((t) => t.id == transaction.id);
//     if (index != -1) {
//       _transactions[index] = transaction;
//       _filteredTransactions = _transactions;
//       notifyListeners();
//     }
//   }

//   Future<void> deleteTransaction(String id) async {
//     await DatabaseService.instance.deleteTransaction(id);
//     _transactions.removeWhere((t) => t.id == id);
//     _filteredTransactions = _transactions;
//     notifyListeners();
//   }

//   Future<void> filterTransactions(
//     String userId, {
//     String? category,
//     DateTime? startDate,
//     DateTime? endDate,
//     String? type,
//   }) async {
//     _filteredTransactions = await DatabaseService.instance.getFilteredTransactions(
//       userId,
//       category: category,
//       startDate: startDate,
//       endDate: endDate,
//       type: type,
//     );
//     notifyListeners();
//   }

//   void clearFilters() {
//     _filteredTransactions = _transactions;
//     notifyListeners();
//   }

//   List<String> get categories => [
//     'Food & Dining',
//     'Transportation',
//     'Shopping',
//     'Entertainment',
//     'Bills & Utilities',
//     'Healthcare',
//     'Education',
//     'Travel',
//     'Salary',
//     'Investment',
//     'Gift',
//     'Other',
//   ];
// }