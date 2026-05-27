import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Thư viện biểu đồ
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';

class ChartWidget extends StatelessWidget {
  const ChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);

    // 1. Lọc và gom nhóm dữ liệu (Chỉ lấy các khoản CHI)
    final expenseTransactions = provider.transactions
        .where((t) => t.isExpense)
        .toList();

    if (expenseTransactions.isEmpty) {
      return const Center(
        child: Text(
          "Chưa có khoản chi tiêu nào để vẽ!",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    Map<String, double> dataMap = {};
    for (var item in expenseTransactions) {
      if (dataMap.containsKey(item.title)) {
        dataMap[item.title] = dataMap[item.title]! + item.amount;
      } else {
        dataMap[item.title] = item.amount;
      }
    }

    // 2. Tạo dữ liệu vẽ
    List<PieChartSectionData> sections = [];
    List<Color> colors = [
      Colors.red.shade400,
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.purple.shade400,
      Colors.teal.shade400,
    ];

    int index = 0;
    dataMap.forEach((title, value) {
      final percent = (value / provider.totalExpense * 100);
      sections.add(
        PieChartSectionData(
          color: colors[index % colors.length],
          value: value,
          title: '${percent.toStringAsFixed(0)}%', // Hiện số %
          radius: 80, // Độ lớn bán kính
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      index++;
    });

    return Column(
      children: [
        // Phần hình tròn
        SizedBox(
          height: 250,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        // Phần chú thích chi tiết bên dưới
        Expanded(
          child: ListView.builder(
            itemCount: dataMap.length,
            itemBuilder: (context, i) {
              String key = dataMap.keys.elementAt(i);
              double value = dataMap[key]!;
              return ListTile(
                leading: Container(
                  width: 16,
                  height: 16,
                  color: colors[i % colors.length],
                ),
                title: Text(key),
                trailing: Text(
                  NumberFormat.simpleCurrency(locale: 'vi_VN').format(value),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
