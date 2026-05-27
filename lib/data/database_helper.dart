import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/transaction_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static const _storageKey = 'transactions';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<void> _saveTransactions(List<TransactionModel> transactions) async {
    final prefs = await _prefs;
    final data = transactions.map((item) => item.toMap()).toList();
    await prefs.setString(_storageKey, jsonEncode(data));
  }

  Future<int> insertTransaction(TransactionModel transaction) async {
    final transactions = await getTransactions();
    final nextId = transactions.isEmpty
        ? 1
        : transactions
                  .map((item) => item.id ?? 0)
                  .reduce((value, item) => value > item ? value : item) +
              1;

    final newTransaction = TransactionModel(
      id: nextId,
      title: transaction.title,
      amount: transaction.amount,
      date: transaction.date,
      isExpense: transaction.isExpense,
    );

    transactions.add(newTransaction);
    await _saveTransactions(transactions);
    return nextId;
  }

  Future<List<TransactionModel>> getTransactions() async {
    final prefs = await _prefs;
    final rawData = prefs.getString(_storageKey);
    if (rawData == null || rawData.isEmpty) return [];

    final decoded = jsonDecode(rawData);
    if (decoded is! List) return [];

    final transactions = decoded
        .whereType<Map>()
        .map(
          (item) => TransactionModel.fromMap(Map<String, dynamic>.from(item)),
        )
        .toList();

    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  Future<int> deleteTransaction(int id) async {
    final transactions = await getTransactions();
    final originalLength = transactions.length;
    transactions.removeWhere((item) => item.id == id);
    await _saveTransactions(transactions);
    return originalLength - transactions.length;
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    final transactions = await getTransactions();
    final index = transactions.indexWhere((item) => item.id == transaction.id);
    if (index == -1) return 0;

    transactions[index] = transaction;
    await _saveTransactions(transactions);
    return 1;
  }
}
