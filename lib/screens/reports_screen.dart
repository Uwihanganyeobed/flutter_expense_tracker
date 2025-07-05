// screens/reports_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMonthSelector(),
            const SizedBox(height: 24),
            _buildMonthlySummary(transactionProvider),
            const SizedBox(height: 24),
            const Text(
              'Category Breakdown',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildCategoryBreakdown(transactionProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedMonth = DateTime(
                    _selectedMonth.year,
                    _selectedMonth.month - 1,
                  );
                });
              },
              icon: const Icon(Icons.arrow_back),
            ),
            Text(
              DateFormat('MMMM yyyy').format(_selectedMonth),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedMonth = DateTime(
                    _selectedMonth.year,
                    _selectedMonth.month + 1,
                  );
                });
              },
              icon: const Icon(Icons.arrow_forward),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlySummary(TransactionProvider transactionProvider) {
    final monthlyTransactions = _getMonthlyTransactions(transactionProvider.transactions);
    final monthlyIncome = monthlyTransactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
    final monthlyExpenses = monthlyTransactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);
    final monthlyBalance = monthlyIncome - monthlyExpenses;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem('Income', monthlyIncome, Colors.green),
                _buildSummaryItem('Expenses', monthlyExpenses, Colors.red),
                _buildSummaryItem('Balance', monthlyBalance, 
                    monthlyBalance >= 0 ? Colors.green : Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, double amount, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          '\${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(TransactionProvider transactionProvider) {
    final monthlyTransactions = _getMonthlyTransactions(transactionProvider.transactions);
    final categoryTotals = <String, double>{};

    for (final transaction in monthlyTransactions) {
      if (transaction.type == 'expense') {
        categoryTotals[transaction.category] = 
            (categoryTotals[transaction.category] ?? 0) + transaction.amount;
      }
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedCategories.isEmpty) {
      return Center(
        child: Text(
          'No expenses for this month',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      itemCount: sortedCategories.length,
      itemBuilder: (context, index) {
        final entry = sortedCategories[index];
        final percentage = (entry.value / monthlyTransactions
            .where((t) => t.type == 'expense')
            .fold(0.0, (sum, t) => sum + t.amount)) * 100;

        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.red,
              child: Icon(Icons.category, color: Colors.white),
            ),
            title: Text(entry.key),
            subtitle: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  '\${entry.value.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Transaction> _getMonthlyTransactions(List<Transaction> transactions) {
    return transactions.where((transaction) {
      return transaction.date.year == _selectedMonth.year &&
          transaction.date.month == _selectedMonth.month;
    }).toList();
  }
}


// // screens/reports_screen.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// import '../providers/transaction_provider.dart';
// import '../models/transaction.dart';

// class ReportsScreen extends StatefulWidget {
//   const ReportsScreen({super.key});

//   @override
//   _ReportsScreenState createState() => _ReportsScreenState();
// }

// class _ReportsScreenState extends State<ReportsScreen> {
//   DateTime _selectedMonth = DateTime.now();

//   @override
//   Widget build(BuildContext context) {
//     final transactionProvider = Provider.of<TransactionProvider>(context);

//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildMonthSelector(),
//             const SizedBox(height: 24),
//             _buildMonthlySummary(transactionProvider),
//             const SizedBox(height: 24),
//             const Text(
//               'Category Breakdown',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
//             Expanded(
//               child: _buildCategoryBreakdown(transactionProvider),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMonthSelector() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             IconButton(
//               onPressed: () {
//                 setState(() {
//                   _selectedMonth = DateTime(
//                     _selectedMonth.year,
//                     _selectedMonth.month - 1,
//                   );
//                 });
//               },
//               icon: const Icon(Icons.arrow_back),
//             ),
//             Text(
//               DateFormat('MMMM yyyy').format(_selectedMonth),
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             IconButton(
//               onPressed: () {
//                 setState(() {
//                   _selectedMonth = DateTime(
//                     _selectedMonth.year,
//                     _selectedMonth.month + 1,
//                   );
//                 });
//               },
//               icon: const Icon(Icons.arrow_forward),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMonthlySummary(TransactionProvider transactionProvider) {
//     final monthlyTransactions = _getMonthlyTransactions(transactionProvider.transactions);
//     final monthlyIncome = monthlyTransactions
//         .where((t) => t.type == 'income')
//         .fold(0.0, (sum, t) => sum + t.amount);
//     final monthlyExpenses = monthlyTransactions
//         .where((t) => t.type == 'expense')
//         .fold(0.0, (sum, t) => sum + t.amount);
//     final monthlyBalance = monthlyIncome - monthlyExpenses;

//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Monthly Summary',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _buildSummaryItem('Income', monthlyIncome, Colors.green),
//                 _buildSummaryItem('Expenses', monthlyExpenses, Colors.red),
//                 _buildSummaryItem('Balance', monthlyBalance, 
//                     monthlyBalance >= 0 ? Colors.green : Colors.red),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSummaryItem(String title, double amount, Color color) {
//     return Column(
//       children: [
//         Text(
//           title,
//           style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           '\${amount.toStringAsFixed(2)}',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCategoryBreakdown(TransactionProvider transactionProvider) {
//     final monthlyTransactions = _getMonthlyTransactions(transactionProvider.transactions);
//     final categoryTotals = <String, double>{};

//     for (final transaction in monthlyTransactions) {
//       if (transaction.type == 'expense') {
//         categoryTotals[transaction.category] = 
//             (categoryTotals[transaction.category] ?? 0) + transaction.amount;
//       }
//     }

//     final sortedCategories = categoryTotals.entries.toList()
//       ..sort((a, b) => b.value.compareTo(a.value));

//     if (sortedCategories.isEmpty) {
//       return Center(
//         child: Text(
//           'No expenses for this month',
//           style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//         ),
//       );
//     }

//     return ListView.builder(
//       itemCount: sortedCategories.length,
//       itemBuilder: (context, index) {
//         final entry = sortedCategories[index];
//         final percentage = (entry.value / monthlyTransactions
//             .where((t) => t.type == 'expense')
//             .fold(0.0, (sum, t) => sum + t.amount)) * 100;

//         return Card(
//           child: ListTile(
//             leading: const CircleAvatar(
//               backgroundColor: Colors.red,
//               child: Icon(Icons.category, color: Colors.white),
//             ),
//             title: Text(entry.key),
//             subtitle: LinearProgressIndicator(
//               value: percentage / 100,
//               backgroundColor: Colors.grey[300],
//               valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
//             ),
//             trailing: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 const Text(
//                   '\${entry.value.toStringAsFixed(2)}',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.red,
//                   ),
//                 ),
//                 Text(
//                   '${percentage.toStringAsFixed(1)}%',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   List<Transaction> _getMonthlyTransactions(List<Transaction> transactions) {
//     return transactions.where((transaction) {
//       return transaction.date.year == _selectedMonth.year &&
//           transaction.date.month == _selectedMonth.month;
//     }).toList();
//   }
// }