import 'package:flutter/material.dart';
import '../api_service.dart';
import '../database_helper.dart';
import '../models/expense.dart';
import '../l10n/app_localizations.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final TextEditingController _amountController = TextEditingController();
  String? _selectedType;
  final List<String> _expenseTypes = ['fuel', 'parking', 'parts', 'other'];
  final TextEditingController _commentController = TextEditingController();
  final ApiService _apiService = ApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Сума витрат',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              hint: Text(AppLocalizations.of(context).translate('expenses')),
              value: _selectedType,
              isExpanded: true,
              items: _expenseTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Коментар',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (_amountController.text.isNotEmpty && _selectedType != null) {
                  final expense = Expense(
                    fuel: _selectedType == 'fuel' ? int.parse(_amountController.text) : null,
                    parking: _selectedType == 'parking' ? int.parse(_amountController.text) : null,
                    parts: _selectedType == 'parts' ? int.parse(_amountController.text) : null,
                    other: _selectedType == 'other' ? int.parse(_amountController.text) : null,
                    comment: _commentController.text,
                    time: DateTime.now().toIso8601String(),
                  );
                  try {
                    await _apiService.addExpense(expense);
                    await _dbHelper.upsertExpense(expense);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context).translate('progressUpdated'))),
                    );
                    _amountController.clear();
                    _commentController.clear();
                    setState(() {
                      _selectedType = null;
                    });
                  } catch (e) {
                    await _dbHelper.upsertExpense(expense);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context).translate('error', args: {'error': e.toString()}))),
                    );
                  }
                }
              },
              child: Text(AppLocalizations.of(context).translate('expenses')),
            ),
          ],
        ),
      ),
    );
  }
}