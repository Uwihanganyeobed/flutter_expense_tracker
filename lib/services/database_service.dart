// services/database_service.dart
// import 'dart:async';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import '../models/user.dart';
// import '../models/transaction.dart' as model;

// class DatabaseService {
//   static final DatabaseService instance = DatabaseService._init();
//   static Database? _database;

//   DatabaseService._init();

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDB('expense_tracker.db');
//     return _database!;
//   }

//   Future<Database> _initDB(String filePath) async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, filePath);

//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: _createDB,
//     );
//   }

//   Future _createDB(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE users (
//         id TEXT PRIMARY KEY,
//         email TEXT UNIQUE NOT NULL,
//         password TEXT NOT NULL,
//         first_name TEXT NOT NULL,
//         last_name TEXT NOT NULL,
//         created_on TEXT NOT NULL
//       )
//     ''');

//     await db.execute('''
//       CREATE TABLE transactions (
//         id TEXT PRIMARY KEY,
//         user_id TEXT NOT NULL,
//         type TEXT NOT NULL,
//         category TEXT NOT NULL,
//         amount REAL NOT NULL,
//         date TEXT NOT NULL,
//         description TEXT,
//         FOREIGN KEY (user_id) REFERENCES users (id)
//       )
//     ''');
//   }

//   Future<void> insertUser(User user) async {
//     final db = await database;
//     await db.insert('users', user.toMap());
//   }

//   Future<User?> getUserByEmail(String email) async {
//     final db = await database;
//     final maps = await db.query(
//       'users',
//       where: 'email = ?',
//       whereArgs: [email],
//     );

//     if (maps.isNotEmpty) {
//       return User.fromMap(maps.first);
//     }
//     return null;
//   }

//   Future<void> insertTransaction(model.Transaction transaction) async {
//     final db = await database;
//     await db.insert('transactions', transaction.toMap());
//   }

//   Future<List<model.Transaction>> getTransactionsByUserId(String userId) async {
//     final db = await database;
//     final maps = await db.query(
//       'transactions',
//       where: 'user_id = ?',
//       whereArgs: [userId],
//       orderBy: 'date DESC',
//     );

//     return maps.map((map) => model.Transaction.fromMap(map)).toList();
//   }

//   Future<void> updateTransaction(model.Transaction transaction) async {
//     final db = await database;
//     await db.update(
//       'transactions',
//       transaction.toMap(),
//       where: 'id = ?',
//       whereArgs: [transaction.id],
//     );
//   }

//   Future<void> deleteTransaction(String id) async {
//     final db = await database;
//     await db.delete(
//       'transactions',
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }

//   Future<List<model.Transaction>> getFilteredTransactions(
//     String userId, {
//     String? category,
//     DateTime? startDate,
//     DateTime? endDate,
//     String? type,
//   }) async {
//     final db = await database;
//     String whereClause = 'user_id = ?';
//     List<dynamic> whereArgs = [userId];

//     if (category != null) {
//       whereClause += ' AND category = ?';
//       whereArgs.add(category);
//     }

//     if (type != null) {
//       whereClause += ' AND type = ?';
//       whereArgs.add(type);
//     }

//     if (startDate != null) {
//       whereClause += ' AND date >= ?';
//       whereArgs.add(startDate.toIso8601String());
//     }

//     if (endDate != null) {
//       whereClause += ' AND date <= ?';
//       whereArgs.add(endDate.toIso8601String());
//     }

//     final maps = await db.query(
//       'transactions',
//       where: whereClause,
//       whereArgs: whereArgs,
//       orderBy: 'date DESC',
//     );

//     return maps.map((map) => model.Transaction.fromMap(map)).toList();
//   }

//   Future close() async {
//     final db = await database;
//     db.close();
//   }
// }

// ___________________________________________________________

import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/transaction.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  SharedPreferences? _prefs;

  DatabaseService._init();

  Future<SharedPreferences> get database async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  // User methods
  Future<void> insertUser(User user) async {
    final prefs = await database;
    final users = await _getUsers();
    users[user.id] = user.toMap();
    await prefs.setString('users', json.encode(users));
  }

  Future<User?> getUserByEmail(String email) async {
    final users = await _getUsers();
    for (final userData in users.values) {
      if (userData['email'] == email) {
        return User.fromMap(userData);
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> _getUsers() async {
    final prefs = await database;
    final usersJson = prefs.getString('users') ?? '{}';
    return Map<String, dynamic>.from(json.decode(usersJson));
  }

  // Transaction methods
  Future<void> insertTransaction(Transaction transaction) async {
    final prefs = await database;
    final transactions = await _getTransactions();
    transactions[transaction.id] = transaction.toMap();
    await prefs.setString('transactions', json.encode(transactions));
  }

  Future<List<Transaction>> getTransactionsByUserId(String userId) async {
    final transactions = await _getTransactions();
    final userTransactions = transactions.values
        .where((t) => t['user_id'] == userId)
        .map((t) => Transaction.fromMap(t))
        .toList();
    
    // Sort by date descending
    userTransactions.sort((a, b) => b.date.compareTo(a.date));
    return userTransactions;
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final prefs = await database;
    final transactions = await _getTransactions();
    transactions[transaction.id] = transaction.toMap();
    await prefs.setString('transactions', json.encode(transactions));
  }

  Future<void> deleteTransaction(String id) async {
    final prefs = await database;
    final transactions = await _getTransactions();
    transactions.remove(id);
    await prefs.setString('transactions', json.encode(transactions));
  }

  Future<List<Transaction>> getFilteredTransactions(
    String userId, {
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    String? type,
  }) async {
    final transactions = await getTransactionsByUserId(userId);
    
    return transactions.where((transaction) {
      if (category != null && transaction.category != category) return false;
      if (type != null && transaction.type != type) return false;
      if (startDate != null && transaction.date.isBefore(startDate)) return false;
      if (endDate != null && transaction.date.isAfter(endDate)) return false;
      return true;
    }).toList();
  }

  Future<Map<String, dynamic>> _getTransactions() async {
    final prefs = await database;
    final transactionsJson = prefs.getString('transactions') ?? '{}';
    return Map<String, dynamic>.from(json.decode(transactionsJson));
  }

  Future<void> close() async {
    // SharedPreferences doesn't need to be closed
  }
}