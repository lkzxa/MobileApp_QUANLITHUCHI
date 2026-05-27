import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import 'add_transaction_screen.dart'; // Để bấm vào sửa được

class TransactionSearchDelegate extends SearchDelegate {
  final List<TransactionModel> allTransactions; // Nhận danh sách để tìm

  TransactionSearchDelegate(this.allTransactions);

  // Text gợi ý trong ô tìm kiếm
  @override
  String? get searchFieldLabel => "Tìm giao dịch (Ví dụ: phở, xăng...)";

  // Nút xóa (bên phải ô tìm kiếm)
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = ''; // Xóa chữ đang nhập
        },
      ),
    ];
  }

  // Nút quay lại (bên trái)
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // Đóng tìm kiếm
      },
    );
  }

  // Hàm hiện kết quả (Dùng chung cho cả lúc gõ và lúc Enter)
  @override
  Widget buildResults(BuildContext context) {
    return _buildList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList(context);
  }

  Widget _buildList(BuildContext context) {
    // Logic lọc: Tìm theo tên
    final results = allTransactions.where((tx) {
      return tx.title.toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Text(
          query.isEmpty
              ? "Nhập từ khóa để tìm..."
              : "Không tìm thấy kết quả nào!",
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final transaction = results[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: transaction.isExpense
                ? Colors.red.withValues(alpha: 0.2)
                : Colors.green.withValues(alpha: 0.2),
            child: Icon(
              transaction.isExpense ? Icons.arrow_downward : Icons.arrow_upward,
              color: transaction.isExpense ? Colors.red : Colors.green,
            ),
          ),
          title: Text(
            transaction.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(DateFormat('dd/MM/yyyy').format(transaction.date)),
          trailing: Text(
            NumberFormat.simpleCurrency(
              locale: 'vi_VN',
            ).format(transaction.amount),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: transaction.isExpense ? Colors.red : Colors.green,
            ),
          ),
          onTap: () {
            // Cho phép bấm vào để Sửa ngay tại màn hình tìm kiếm
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AddTransactionScreen(transaction: transaction),
              ),
            );
          },
        );
      },
    );
  }
}
