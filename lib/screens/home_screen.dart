// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import 'transaction_form_screen.dart';
import 'reports_screen.dart';
import 'transactions_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      if (authProvider.currentUser != null) {
        transactionProvider.loadTransactions(authProvider.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);

    final screens = [
      _buildDashboard(transactionProvider),
      TransactionsScreen(),
      ReportsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                authProvider.signOut();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Reports',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TransactionFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDashboard(TransactionProvider transactionProvider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Income',
                  transactionProvider.totalIncome,
                  Colors.green,
                  Icons.trending_up,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Total Expenses',
                  transactionProvider.totalExpenses,
                  Colors.red,
                  Icons.trending_down,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            'Balance',
            transactionProvider.balance,
            transactionProvider.balance >= 0 ? Colors.green : Colors.red,
            Icons.account_balance_wallet,
          ),
          const SizedBox(height: 24),
          const Text(
            'Recent Transactions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: transactionProvider.transactions.isEmpty
                ? Center(
                    child: Text(
                      'No transactions yet\nTap + to add your first transaction',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    itemCount: transactionProvider.transactions.length > 5
                        ? 5
                        : transactionProvider.transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactionProvider.transactions[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: transaction.type == 'income'
                                ? Colors.green
                                : Colors.red,
                            child: Icon(
                              transaction.type == 'income'
                                  ? Icons.add
                                  : Icons.remove,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(transaction.category),
                          subtitle: Text(transaction.description),
                          trailing: Text(
                            '\$${transaction.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: transaction.type == 'income'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color, IconData icon) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// // screens/home_screen.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/auth_provider.dart';
// import '../providers/transaction_provider.dart';
// import 'transaction_form_screen.dart';
// import 'reports_screen.dart';
// import 'transactions_screen.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _selectedIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
//       if (authProvider.currentUser != null) {
//         transactionProvider.loadTransactions(authProvider.currentUser!.id);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthProvider>(context);
//     final transactionProvider = Provider.of<TransactionProvider>(context);

//     final screens = [
//       _buildDashboard(transactionProvider),
//       TransactionsScreen(),
//       ReportsScreen(),
//     ];

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Expense Tracker'),
//         actions: [
//           PopupMenuButton<String>(
//             onSelected: (value) {
//               if (value == 'logout') {
//                 authProvider.signOut();
//               }
//             },
//             itemBuilder: (context) => [
//               const PopupMenuItem(
//                 value: 'logout',
//                 child: Row(
//                   children: [
//                     Icon(Icons.logout),
//                     SizedBox(width: 8),
//                     Text('Logout'),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//       body: screens[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: (index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//         },
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.dashboard),
//             label: 'Dashboard',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.list),
//             label: 'Transactions',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.analytics),
//             label: 'Reports',
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => TransactionFormScreen()),
//           );
//         },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }

//   Widget _buildDashboard(TransactionProvider transactionProvider) {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: _buildSummaryCard(
//                   'Total Income',
//                   transactionProvider.totalIncome,
//                   Colors.green,
//                   Icons.trending_up,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: _buildSummaryCard(
//                   'Total Expenses',
//                   transactionProvider.totalExpenses,
//                   Colors.red,
//                   Icons.trending_down,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           _buildSummaryCard(
//             'Balance',
//             transactionProvider.balance,
//             transactionProvider.balance >= 0 ? Colors.green : Colors.red,
//             Icons.account_balance_wallet,
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'Recent Transactions',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 16),
//           Expanded(
//             child: transactionProvider.transactions.isEmpty
//                 ? Center(
//                     child: Text(
//                       'No transactions yet\nTap + to add your first transaction',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//                     ),
//                   )
//                 : ListView.builder(
//                     itemCount: transactionProvider.transactions.length > 5
//                         ? 5
//                         : transactionProvider.transactions.length,
//                     itemBuilder: (context, index) {
//                       final transaction = transactionProvider.transactions[index];
//                       return Card(
//                         child: ListTile(
//                           leading: CircleAvatar(
//                             backgroundColor: transaction.type == 'income'
//                                 ? Colors.green
//                                 : Colors.red,
//                             child: Icon(
//                               transaction.type == 'income'
//                                   ? Icons.add
//                                   : Icons.remove,
//                               color: Colors.white,
//                             ),
//                           ),
//                           title: Text(transaction.category),
//                           subtitle: Text(transaction.description),
//                           trailing: Text(
//                             '\$${transaction.amount.toStringAsFixed(2)}',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: transaction.type == 'income'
//                                   ? Colors.green
//                                   : Colors.red,
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSummaryCard(String title, double amount, Color color, IconData icon) {
//     return Card(
//       elevation: 4,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(icon, color: color),
//                 const SizedBox(width: 8),
//                 Text(
//                   title,
//                   style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Text(
//               '\$${amount.toStringAsFixed(2)}',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }