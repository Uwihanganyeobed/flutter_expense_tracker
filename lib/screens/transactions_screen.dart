// screens/transactions_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/auth_provider.dart';
import '../models/transaction.dart';
import 'transaction_form_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String? _selectedCategory;
  String? _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Column(
        children: [
          _buildFilterSection(transactionProvider, authProvider),
          Expanded(
            child: transactionProvider.filteredTransactions.isEmpty
                ? Center(
                    child: Text(
                      'No transactions found',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    itemCount: transactionProvider.filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactionProvider.filteredTransactions[index];
                      return _buildTransactionCard(transaction, transactionProvider);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(TransactionProvider transactionProvider, AuthProvider authProvider) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filters',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All Types')),
                      DropdownMenuItem(value: 'income', child: Text('Income')),
                      DropdownMenuItem(value: 'expense', child: Text('Expense')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value;
                      });
                      _applyFilters(transactionProvider, authProvider);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Categories')),
                      ...transactionProvider.categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                      _applyFilters(transactionProvider, authProvider);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Start Date'),
                    subtitle: Text(_startDate != null 
                        ? DateFormat('yyyy-MM-dd').format(_startDate!) 
                        : 'Not set'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _startDate = date;
                        });
                        _applyFilters(transactionProvider, authProvider);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('End Date'),
                    subtitle: Text(_endDate != null 
                        ? DateFormat('yyyy-MM-dd').format(_endDate!) 
                        : 'Not set'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _endDate = date;
                        });
                        _applyFilters(transactionProvider, authProvider);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = null;
                  _selectedType = null;
                  _startDate = null;
                  _endDate = null;
                });
                transactionProvider.clearFilters();
              },
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction, TransactionProvider transactionProvider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: transaction.type == 'income' ? Colors.green : Colors.red,
          child: Icon(
            transaction.type == 'income' ? Icons.add : Icons.remove,
            color: Colors.white,
          ),
        ),
        title: Text(
          transaction.category,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(transaction.description),
            const SizedBox(height: 4),
            Text(
              DateFormat('yyyy-MM-dd').format(transaction.date),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '\${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: transaction.type == 'income' ? Colors.green : Colors.red,
                fontSize: 16,
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransactionFormScreen(transaction: transaction),
                    ),
                  );
                } else if (value == 'delete') {
                  _showDeleteDialog(transaction, transactionProvider);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _applyFilters(TransactionProvider transactionProvider, AuthProvider authProvider) {
    transactionProvider.filterTransactions(
      authProvider.currentUser!.id,
      category: _selectedCategory,
      type: _selectedType,
      startDate: _startDate,
      endDate: _endDate,
    );
  }

  void _showDeleteDialog(Transaction transaction, TransactionProvider transactionProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await transactionProvider.deleteTransaction(transaction.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transaction deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// // screens/transactions_screen.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// import '../providers/transaction_provider.dart';
// import '../providers/auth_provider.dart';
// import '../models/transaction.dart';
// import 'transaction_form_screen.dart';

// class TransactionsScreen extends StatefulWidget {
//   const TransactionsScreen({super.key});

//   @override
//   _TransactionsScreenState createState() => _TransactionsScreenState();
// }

// class _TransactionsScreenState extends State<TransactionsScreen> {
//   String? _selectedCategory;
//   String? _selectedType;
//   DateTime? _startDate;
//   DateTime? _endDate;

//   @override
//   Widget build(BuildContext context) {
//     final transactionProvider = Provider.of<TransactionProvider>(context);
//     final authProvider = Provider.of<AuthProvider>(context);

//     return Scaffold(
//       body: Column(
//         children: [
//           _buildFilterSection(transactionProvider, authProvider),
//           Expanded(
//             child: transactionProvider.filteredTransactions.isEmpty
//                 ? Center(
//                     child: Text(
//                       'No transactions found',
//                       style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//                     ),
//                   )
//                 : ListView.builder(
//                     itemCount: transactionProvider.filteredTransactions.length,
//                     itemBuilder: (context, index) {
//                       final transaction = transactionProvider.filteredTransactions[index];
//                       return _buildTransactionCard(transaction, transactionProvider);
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilterSection(TransactionProvider transactionProvider, AuthProvider authProvider) {
//     return Card(
//       margin: const EdgeInsets.all(8),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Filters',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: DropdownButtonFormField<String>(
//                     value: _selectedType,
//                     decoration: const InputDecoration(
//                       labelText: 'Type',
//                       border: OutlineInputBorder(),
//                       contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                     ),
//                     items: const [
//                       DropdownMenuItem(value: null, child: Text('All Types')),
//                       DropdownMenuItem(value: 'income', child: Text('Income')),
//                       DropdownMenuItem(value: 'expense', child: Text('Expense')),
//                     ],
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedType = value;
//                       });
//                       _applyFilters(transactionProvider, authProvider);
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: DropdownButtonFormField<String>(
//                     value: _selectedCategory,
//                     decoration: const InputDecoration(
//                       labelText: 'Category',
//                       border: OutlineInputBorder(),
//                       contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                     ),
//                     items: [
//                       const DropdownMenuItem(value: null, child: Text('All Categories')),
//                       ...transactionProvider.categories.map((category) {
//                         return DropdownMenuItem(
//                           value: category,
//                           child: Text(category),
//                         );
//                       }),
//                     ],
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedCategory = value;
//                       });
//                       _applyFilters(transactionProvider, authProvider);
//                     },
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: ListTile(
//                     contentPadding: EdgeInsets.zero,
//                     title: const Text('Start Date'),
//                     subtitle: Text(_startDate != null 
//                         ? DateFormat('yyyy-MM-dd').format(_startDate!) 
//                         : 'Not set'),
//                     trailing: const Icon(Icons.calendar_today),
//                     onTap: () async {
//                       final date = await showDatePicker(
//                         context: context,
//                         initialDate: _startDate ?? DateTime.now(),
//                         firstDate: DateTime(2000),
//                         lastDate: DateTime.now(),
//                       );
//                       if (date != null) {
//                         setState(() {
//                           _startDate = date;
//                         });
//                         _applyFilters(transactionProvider, authProvider);
//                       }
//                     },
//                   ),
//                 ),
//                 Expanded(
//                   child: ListTile(
//                     contentPadding: EdgeInsets.zero,
//                     title: const Text('End Date'),
//                     subtitle: Text(_endDate != null 
//                         ? DateFormat('yyyy-MM-dd').format(_endDate!) 
//                         : 'Not set'),
//                     trailing: const Icon(Icons.calendar_today),
//                     onTap: () async {
//                       final date = await showDatePicker(
//                         context: context,
//                         initialDate: _endDate ?? DateTime.now(),
//                         firstDate: DateTime(2000),
//                         lastDate: DateTime.now(),
//                       );
//                       if (date != null) {
//                         setState(() {
//                           _endDate = date;
//                         });
//                         _applyFilters(transactionProvider, authProvider);
//                       }
//                     },
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   _selectedCategory = null;
//                   _selectedType = null;
//                   _startDate = null;
//                   _endDate = null;
//                 });
//                 transactionProvider.clearFilters();
//               },
//               child: const Text('Clear Filters'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTransactionCard(Transaction transaction, TransactionProvider transactionProvider) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundColor: transaction.type == 'income' ? Colors.green : Colors.red,
//           child: Icon(
//             transaction.type == 'income' ? Icons.add : Icons.remove,
//             color: Colors.white,
//           ),
//         ),
//         title: Text(
//           transaction.category,
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(transaction.description),
//             const SizedBox(height: 4),
//             Text(
//               DateFormat('yyyy-MM-dd').format(transaction.date),
//               style: TextStyle(color: Colors.grey[600], fontSize: 12),
//             ),
//           ],
//         ),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               '\${transaction.amount.toStringAsFixed(2)}',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: transaction.type == 'income' ? Colors.green : Colors.red,
//                 fontSize: 16,
//               ),
//             ),
//             PopupMenuButton<String>(
//               onSelected: (value) {
//                 if (value == 'edit') {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => TransactionFormScreen(transaction: transaction),
//                     ),
//                   );
//                 } else if (value == 'delete') {
//                   _showDeleteDialog(transaction, transactionProvider);
//                 }
//               },
//               itemBuilder: (context) => [
//                 const PopupMenuItem(
//                   value: 'edit',
//                   child: Row(
//                     children: [
//                       Icon(Icons.edit),
//                       SizedBox(width: 8),
//                       Text('Edit'),
//                     ],
//                   ),
//                 ),
//                 const PopupMenuItem(
//                   value: 'delete',
//                   child: Row(
//                     children: [
//                       Icon(Icons.delete, color: Colors.red),
//                       SizedBox(width: 8),
//                       Text('Delete', style: TextStyle(color: Colors.red)),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _applyFilters(TransactionProvider transactionProvider, AuthProvider authProvider) {
//     transactionProvider.filterTransactions(
//       authProvider.currentUser!.id,
//       category: _selectedCategory,
//       type: _selectedType,
//       startDate: _startDate,
//       endDate: _endDate,
//     );
//   }

//   void _showDeleteDialog(Transaction transaction, TransactionProvider transactionProvider) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Transaction'),
//         content: const Text('Are you sure you want to delete this transaction?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               await transactionProvider.deleteTransaction(transaction.id);
//               Navigator.pop(context);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Transaction deleted successfully'),
//                   backgroundColor: Colors.green,
//                 ),
//               );
//             },
//             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
// }