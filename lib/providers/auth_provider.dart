// providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user.dart';
import '../services/database_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final existingUser = await DatabaseService.instance.getUserByEmail(email);
      if (existingUser != null) {
        return false; // User already exists
      }

      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        password: _hashPassword(password),
        firstName: firstName,
        lastName: lastName,
        createdOn: DateTime.now(),
      );

      await DatabaseService.instance.insertUser(user);
      _currentUser = user;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await DatabaseService.instance.getUserByEmail(email);
      if (user != null && user.password == _hashPassword(password)) {
        _currentUser = user;
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void signOut() {
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}


// // providers/auth_provider.dart
// import 'package:flutter/foundation.dart';
// import 'package:crypto/crypto.dart';
// import 'dart:convert';
// import '../models/user.dart';
// import '../services/database_service.dart';

// class AuthProvider extends ChangeNotifier {
//   User? _currentUser;
//   bool _isAuthenticated = false;

//   User? get currentUser => _currentUser;
//   bool get isAuthenticated => _isAuthenticated;

//   String _hashPassword(String password) {
//     var bytes = utf8.encode(password);
//     var digest = sha256.convert(bytes);
//     return digest.toString();
//   }

//   Future<bool> signUp({
//     required String email,
//     required String password,
//     required String firstName,
//     required String lastName,
//   }) async {
//     try {
//       final existingUser = await DatabaseService.instance.getUserByEmail(email);
//       if (existingUser != null) {
//         return false; // User already exists
//       }

//       final user = User(
//         id: DateTime.now().millisecondsSinceEpoch.toString(),
//         email: email,
//         password: _hashPassword(password),
//         firstName: firstName,
//         lastName: lastName,
//         createdOn: DateTime.now(),
//       );

//       await DatabaseService.instance.insertUser(user);
//       _currentUser = user;
//       _isAuthenticated = true;
//       notifyListeners();
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }

//   Future<bool> signIn({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final user = await DatabaseService.instance.getUserByEmail(email);
//       if (user != null && user.password == _hashPassword(password)) {
//         _currentUser = user;
//         _isAuthenticated = true;
//         notifyListeners();
//         return true;
//       }
//       return false;
//     } catch (e) {
//       return false;
//     }
//   }

//   void signOut() {
//     _currentUser = null;
//     _isAuthenticated = false;
//     notifyListeners();
//   }
// }
