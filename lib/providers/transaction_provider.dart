import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/transaction_model.dart';

class TransactionProvider with ChangeNotifier {
  // Dữ liệu gốc từ Database
  List<TransactionModel> _allTransactions = [];

  // Biến lưu tháng đang chọn (Mặc định là hôm nay)
  DateTime _selectedDate = DateTime.now();

  // --- GETTER (LẤY DỮ LIỆU) ---

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  List<TransactionModel> get allTransactions => _allTransactions;
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // 1. Chỉ lấy giao dịch thuộc tháng và năm đang chọn
  List<TransactionModel> get transactions {
    return _allTransactions.where((tx) {
      return tx.date.month == _selectedDate.month &&
          tx.date.year == _selectedDate.year;
    }).toList();
  }

  // 2. Tính tổng thu (Của tháng đang chọn)
  double get totalIncome {
    return transactions
        .where((tx) => !tx.isExpense)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // 3. Tính tổng chi (Của tháng đang chọn)
  double get totalExpense {
    return transactions
        .where((tx) => tx.isExpense)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // 4. Số dư (Của tháng đang chọn)
  double get balance => totalIncome - totalExpense;

  // 5. Getter ngày đang chọn để hiện lên màn hình
  DateTime get selectedDate => _selectedDate;

  // Các hàm gợi ý (Giữ nguyên)
  List<String> get titleSuggestions =>
      _allTransactions.map((e) => e.title).toSet().toList();
  List<String> get amountSuggestions =>
      _allTransactions.map((e) => e.amount.toInt().toString()).toSet().toList();

  // --- HÀM XỬ LÝ ---

  // Đổi tháng (Bộ lọc)
  void changeMonth(DateTime newDate) {
    _selectedDate = newDate;
    notifyListeners(); // Báo màn hình vẽ lại theo tháng mới
  }

  Future<void> loadTransactions() async {
    _allTransactions = await DatabaseHelper().getTransactions();
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await DatabaseHelper().insertTransaction(transaction);
    await loadTransactions();
  }

  // Cập nhật (Sửa)
  Future<void> updateTransaction(TransactionModel transaction) async {
    await DatabaseHelper().updateTransaction(transaction);
    await loadTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await DatabaseHelper().deleteTransaction(id);
    await loadTransactions();
  }
}
