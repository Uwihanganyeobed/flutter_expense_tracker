// screens/transaction_form_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';

class TransactionFormScreen extends StatefulWidget {
  final Transaction? transaction;

  const TransactionFormScreen({super.key, this.transaction});

  @override
  _TransactionFormScreenState createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedType = 'expense';
  String _selectedCategory = 'Food & Dining';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _amountController.text = widget.transaction!.amount.toString();
      _descriptionController.text = widget.transaction!.description;
      _selectedType = widget.transaction!.type;
      _selectedCategory = widget.transaction!.category;
      _selectedDate = widget.transaction!.date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction == null ? 'Add Transaction' : 'Edit Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Income'),
                      value: 'income',
                      groupValue: _selectedType,
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Expense'),
                      value: 'expense',
                      groupValue: _selectedType,
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: transactionProvider.categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => _saveTransaction(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 0),
                ),
                child: Text(widget.transaction == null ? 'Add Transaction' : 'Update Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTransaction(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);

      final transaction = Transaction(
        id: widget.transaction?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: authProvider.currentUser!.id,
        type: _selectedType,
        category: _selectedCategory,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        description: _descriptionController.text,
      );

      try {
        if (widget.transaction == null) {
          await transactionProvider.addTransaction(transaction);
        } else {
          await transactionProvider.updateTransaction(transaction);
        }
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.transaction == null 
                ? 'Transaction added successfully' 
                : 'Transaction updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error saving transaction'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}






// // screens/transaction_form_screen.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// import '../providers/auth_provider.dart';
// import '../providers/transaction_provider.dart';
// import '../models/transaction.dart';

// class TransactionFormScreen extends StatefulWidget {
//   final Transaction? transaction;

//   const TransactionFormScreen({super.key, this.transaction});

//   @override
//   _TransactionFormScreenState createState() => _TransactionFormScreenState();
// }

// class _TransactionFormScreenState extends State<TransactionFormScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _amountController = TextEditingController();
//   final _descriptionController = TextEditingController();
  
//   String _selectedType = 'expense';
//   String _selectedCategory = 'Food & Dining';
//   DateTime _selectedDate = DateTime.now();

//   @override
//   void initState() {
//     super.initState();
//     if (widget.transaction != null) {
//       _amountController.text = widget.transaction!.amount.toString();
//       _descriptionController.text = widget.transaction!.description;
//       _selectedType = widget.transaction!.type;
//       _selectedCategory = widget.transaction!.category;
//       _selectedDate = widget.transaction!.date;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final transactionProvider = Provider.of<TransactionProvider>(context);
    
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.transaction == null ? 'Add Transaction' : 'Edit Transaction'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: RadioListTile<String>(
//                       title: const Text('Income'),
//                       value: 'income',
//                       groupValue: _selectedType,
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedType = value!;
//                         });
//                       },
//                     ),
//                   ),
//                   Expanded(
//                     child: RadioListTile<String>(
//                       title: const Text('Expense'),
//                       value: 'expense',
//                       groupValue: _selectedType,
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedType = value!;
//                         });
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _amountController,
//                 keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                 decoration: const InputDecoration(
//                   labelText: 'Amount',
//                   prefixIcon: Icon(Icons.attach_money),
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter amount';
//                   }
//                   if (double.tryParse(value) == null) {
//                     return 'Please enter a valid number';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 value: _selectedCategory,
//                 decoration: const InputDecoration(
//                   labelText: 'Category',
//                   prefixIcon: Icon(Icons.category),
//                   border: OutlineInputBorder(),
//                 ),
//                 items: transactionProvider.categories.map((category) {
//                   return DropdownMenuItem(
//                     value: category,
//                     child: Text(category),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     _selectedCategory = value!;
//                   });
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _descriptionController,
//                 decoration: const InputDecoration(
//                   labelText: 'Description',
//                   prefixIcon: Icon(Icons.description),
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 3,
//               ),
//               const SizedBox(height: 16),
//               ListTile(
//                 leading: const Icon(Icons.calendar_today),
//                 title: const Text('Date'),
//                 subtitle: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
//                 trailing: const Icon(Icons.keyboard_arrow_right),
//                 onTap: () async {
//                   final date = await showDatePicker(
//                     context: context,
//                     initialDate: _selectedDate,
//                     firstDate: DateTime(2000),
//                     lastDate: DateTime.now(),
//                   );
//                   if (date != null) {
//                     setState(() {
//                       _selectedDate = date;
//                     });
//                   }
//                 },
//               ),
//               const SizedBox(height: 32),
//               ElevatedButton(
//                 onPressed: () => _saveTransaction(context),
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   minimumSize: const Size(double.infinity, 0),
//                 ),
//                 child: Text(widget.transaction == null ? 'Add Transaction' : 'Update Transaction'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _saveTransaction(BuildContext context) async {
//     if (_formKey.currentState!.validate()) {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);

//       final transaction = Transaction(
//         id: widget.transaction?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
//         userId: authProvider.currentUser!.id,
//         type: _selectedType,
//         category: _selectedCategory,
//         amount: double.parse(_amountController.text),
//         date: _selectedDate,
//         description: _descriptionController.text,
//       );

//       try {
//         if (widget.transaction == null) {
//           await transactionProvider.addTransaction(transaction);
//         } else {
//           await transactionProvider.updateTransaction(transaction);
//         }
//         Navigator.pop(context);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(widget.transaction == null 
//                 ? 'Transaction added successfully' 
//                 : 'Transaction updated successfully'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Error saving transaction'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }
// }