import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  // Thêm biến này để nhận dữ liệu cũ nếu là chế độ Sửa
  final TransactionModel? transaction;
  final DateTime? initialDate;

  const AddTransactionScreen({super.key, this.transaction, this.initialDate});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isExpense = true;
  bool _isSaving = false;
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Nếu có dữ liệu truyền vào -> Đây là chế độ SỬA -> Điền sẵn dữ liệu cũ
    if (widget.transaction != null) {
      _selectedDate = widget.transaction!.date;
      _isExpense = widget.transaction!.isExpense;

      // Gán vào controller để hiện lên ô nhập
      _titleController.text = widget.transaction!.title;
      _amountController.text = widget.transaction!.amount.toInt().toString();
    } else if (widget.initialDate != null) {
      _selectedDate = widget.initialDate!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  double _parseAmount(String value) {
    final normalized = value.trim().replaceAll(RegExp(r'[\s,.]'), '');
    return double.tryParse(normalized) ?? 0;
  }

  Future<void> _submitData() async {
    final title = _titleController.text.trim();
    final enteredAmount = _parseAmount(_amountController.text);

    if (title.isEmpty || enteredAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập tiêu đề và số tiền hợp lệ."),
        ),
      );
      return;
    }

    final provider = Provider.of<TransactionProvider>(context, listen: false);

    setState(() => _isSaving = true);
    try {
      final transaction = TransactionModel(
        id: widget.transaction?.id,
        title: title,
        amount: enteredAmount,
        date: _selectedDate,
        isExpense: _isExpense,
      );

      if (widget.transaction == null) {
        await provider.addTransaction(transaction);
      } else {
        await provider.updateTransaction(transaction);
      }

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không lưu được giao dịch: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        // Đổi tiêu đề tùy theo chế độ
        title: Text(
          widget.transaction == null ? "Thêm Giao Dịch" : "Sửa Giao Dịch",
        ),
        backgroundColor: _isExpense
            ? Colors.red.shade100
            : Colors.green.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Autocomplete<String>(
              optionsBuilder: (v) => v.text.isEmpty
                  ? []
                  : provider.titleSuggestions.where(
                      (e) => e.toLowerCase().contains(v.text.toLowerCase()),
                    ),
              onSelected: (val) => _titleController.text = val,
              fieldViewBuilder:
                  (context, controller, focusNode, onEditingComplete) {
                    // Nếu là lần đầu mở form sửa, dùng controller riêng để hiện text cũ
                    if (controller.text.isEmpty &&
                        _titleController.text.isNotEmpty) {
                      controller.text = _titleController.text;
                    }
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(labelText: 'Tiêu đề'),
                      onChanged: (val) => _titleController.text = val,
                    );
                  },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Số tiền'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text("Loại: "),
                Switch(
                  value: _isExpense,
                  activeThumbColor: Colors.red,
                  inactiveThumbColor: Colors.green,
                  onChanged: (val) => setState(() => _isExpense = val),
                ),
                Text(
                  _isExpense ? "Chi Tiêu" : "Thu Nhập",
                  style: TextStyle(
                    color: _isExpense ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isSaving ? null : _submitData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 50,
                ),
              ),
              child: Text(
                _isSaving
                    ? "ĐANG LƯU..."
                    : widget.transaction == null
                    ? "LƯU"
                    : "CẬP NHẬT",
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
