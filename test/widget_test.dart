import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_quan_ly_chi_tieu/data/database_helper.dart';
import 'package:app_quan_ly_chi_tieu/models/transaction_model.dart';

void main() {
  test('TransactionModel maps SQLite values correctly', () {
    final transaction = TransactionModel(
      id: 1,
      title: 'An trua',
      amount: 50000,
      date: DateTime(2026, 5, 27),
      isExpense: true,
    );

    final map = transaction.toMap();
    final restored = TransactionModel.fromMap(map);

    expect(restored.id, 1);
    expect(restored.title, 'An trua');
    expect(restored.amount, 50000);
    expect(restored.date, DateTime(2026, 5, 27));
    expect(restored.isExpense, isTrue);
  });

  test('DatabaseHelper saves transactions in local storage', () async {
    SharedPreferences.setMockInitialValues({});

    final database = DatabaseHelper();
    final id = await database.insertTransaction(
      TransactionModel(
        title: 'Luong thang 5',
        amount: 9000000,
        date: DateTime(2026, 5, 27),
        isExpense: false,
      ),
    );

    final transactions = await database.getTransactions();

    expect(id, 1);
    expect(transactions, hasLength(1));
    expect(transactions.first.title, 'Luong thang 5');
    expect(transactions.first.amount, 9000000);
    expect(transactions.first.isExpense, isFalse);
  });
}
