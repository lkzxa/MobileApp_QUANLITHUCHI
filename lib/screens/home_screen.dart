import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// --- CÁC IMPORT CẦN THIẾT ---
import '../providers/transaction_provider.dart';
import 'add_transaction_screen.dart';
import '../widgets/chart_widget.dart';
import 'search_transaction.dart'; // Đảm bảo bạn đã tạo file này ở bước trước

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showChart = false; // Biến kiểm soát xem Biểu đồ hay Danh sách

  @override
  void initState() {
    super.initState();
    // Tải dữ liệu khi mở màn hình
    Provider.of<TransactionProvider>(context, listen: false).loadTransactions();
  }

  // --- HÀM 1: CHỌN ICON THÔNG MINH ---
  IconData _getSmartIcon(String title, bool isExpense) {
    if (!isExpense) {
      String t = title.toLowerCase();
      if (t.contains('lương') || t.contains('thưởng')) {
        return Icons.attach_money;
      }
      if (t.contains('lì xì') || t.contains('biếu')) return Icons.card_giftcard;
      if (t.contains('lãi') || t.contains('bán')) return Icons.trending_up;
      return Icons.account_balance_wallet;
    }

    String t = title.toLowerCase();
    // Di chuyển
    if (t.contains('xăng')) return Icons.local_gas_station;
    if (t.contains('xe') ||
        t.contains('bảo dưỡng') ||
        t.contains('rửa') ||
        t.contains('gửi')) {
      return Icons.motorcycle;
    }
    if (t.contains('grab') ||
        t.contains('be') ||
        t.contains('taxi') ||
        t.contains('vé')) {
      return Icons.local_taxi;
    }
    // Ăn uống
    if (t.contains('cafe') ||
        t.contains('cà phê') ||
        t.contains('trà') ||
        t.contains('nước')) {
      return Icons.local_cafe;
    }
    if (t.contains('nhậu') || t.contains('bia') || t.contains('rượu')) {
      return Icons.sports_bar;
    }
    if (t.contains('ăn') ||
        t.contains('cơm') ||
        t.contains('phở') ||
        t.contains('bún') ||
        t.contains('mì') ||
        t.contains('lẩu') ||
        t.contains('thịt') ||
        t.contains('rau')) {
      return Icons.restaurant;
    }
    // Nhà cửa
    if (t.contains('điện')) return Icons.electric_bolt;
    if (t.contains('nước') && !t.contains('uống')) return Icons.water_drop;
    if (t.contains('mạng') ||
        t.contains('wifi') ||
        t.contains('4g') ||
        t.contains('5g') ||
        t.contains('nạp')) {
      return Icons.wifi;
    }
    if (t.contains('nhà') || t.contains('trọ')) return Icons.home;
    // Mua sắm
    if (t.contains('mua') ||
        t.contains('sắm') ||
        t.contains('shopee') ||
        t.contains('lazada') ||
        t.contains('tiktok') ||
        t.contains('siêu thị')) {
      return Icons.shopping_cart;
    }
    if (t.contains('quần') || t.contains('áo') || t.contains('giày')) {
      return Icons.checkroom;
    }
    // Sức khỏe & Học tập
    if (t.contains('thuốc') || t.contains('khám') || t.contains('bệnh')) {
      return Icons.medical_services;
    }
    if (t.contains('học') || t.contains('sách') || t.contains('vở')) {
      return Icons.school;
    }

    return Icons.category; // Mặc định
  }

  // --- HÀM 2: CHỌN THÁNG ---
  void _pickMonth(BuildContext context) async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final selected = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (selected != null) {
      provider.changeMonth(selected);
    }
  }

  // --- HÀM 3: XÁC NHẬN XÓA ---
  void _confirmDelete(BuildContext context, int id, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xóa giao dịch?"),
        content: Text("Bạn có chắc muốn xóa '$title' không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () {
              Provider.of<TransactionProvider>(
                context,
                listen: false,
              ).deleteTransaction(id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Đã xóa thành công!")),
              );
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dùng Consumer để lắng nghe thay đổi (Data + DarkMode)
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          // --- MENU BÊN TRÁI (DRAWER) ---
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        size: 50,
                        color: Colors.white,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Cài Đặt",
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(
                    provider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  ),
                  title: const Text("Chế độ tối"),
                  trailing: Switch(
                    value: provider.isDarkMode,
                    onChanged: (val) {
                      provider.toggleTheme(); // Bật tắt Dark Mode
                    },
                  ),
                ),
              ],
            ),
          ),

          // --- THANH APP BAR ---
          appBar: AppBar(
            title: const Text("Sổ Thu Chi"),
            centerTitle: true,
            // Không set backgroundColor cứng để nó tự đổi theo Dark Mode
            actions: [
              // Nút Tìm kiếm
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: TransactionSearchDelegate(
                      provider.allTransactions,
                    ),
                  );
                },
              ),
            ],
          ),

          // Nút Thêm giao dịch (+)
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    AddTransactionScreen(initialDate: provider.selectedDate),
              ),
            ),
            child: const Icon(Icons.add),
          ),

          // --- PHẦN THÂN (BODY) ---
          body: Column(
            children: [
              // 1. THANH CHỌN THÁNG
              Container(
                color: provider.isDarkMode
                    ? Colors.grey[900]
                    : Colors.grey.shade200, // Màu nền thay đổi theo theme
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_left),
                      onPressed: () => provider.changeMonth(
                        DateTime(
                          provider.selectedDate.year,
                          provider.selectedDate.month - 1,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _pickMonth(context),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month, color: Colors.blue),
                          const SizedBox(width: 5),
                          Text(
                            "Tháng ${provider.selectedDate.month}/${provider.selectedDate.year}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_right),
                      onPressed: () => provider.changeMonth(
                        DateTime(
                          provider.selectedDate.year,
                          provider.selectedDate.month + 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. DASHBOARD (SỐ DƯ)
              Card(
                margin: const EdgeInsets.all(16),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        "Số dư tháng này",
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        NumberFormat.simpleCurrency(
                          locale: 'vi_VN',
                        ).format(provider.balance),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: provider.balance >= 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Thu: ${NumberFormat.simpleCurrency(locale: 'vi_VN').format(provider.totalIncome)}",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Chi: ${NumberFormat.simpleCurrency(locale: 'vi_VN').format(provider.totalExpense)}",
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 3. NÚT CHUYỂN TAB (DANH SÁCH / BIỂU ĐỒ)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text("Danh sách"),
                    selected: !_showChart,
                    onSelected: (val) => setState(() => _showChart = false),
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text("Biểu đồ"),
                    selected: _showChart,
                    onSelected: (val) => setState(() => _showChart = true),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 4. KHU VỰC HIỂN THỊ NỘI DUNG
              Expanded(
                child: _showChart
                    // Nếu chọn Biểu đồ
                    ? const ChartWidget()
                    // Nếu chọn Danh sách
                    : provider.transactions.isEmpty
                    ? const Center(child: Text("Tháng này chưa có giao dịch!"))
                    : ListView.builder(
                        itemCount: provider.transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = provider.transactions[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: ListTile(
                              // Icon thông minh
                              leading: CircleAvatar(
                                backgroundColor: transaction.isExpense
                                    ? Colors.red.withValues(alpha: 0.2)
                                    : Colors.green.withValues(alpha: 0.2),
                                child: Icon(
                                  _getSmartIcon(
                                    transaction.title,
                                    transaction.isExpense,
                                  ),
                                  color: transaction.isExpense
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ),
                              // Thông tin giao dịch
                              title: Text(
                                transaction.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                DateFormat('dd/MM').format(transaction.date),
                              ),
                              trailing: Text(
                                NumberFormat.simpleCurrency(
                                  locale: 'vi_VN',
                                ).format(transaction.amount),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: transaction.isExpense
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ),
                              // Sự kiện bấm vào để SỬA
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => AddTransactionScreen(
                                      transaction: transaction,
                                    ),
                                  ),
                                );
                              },
                              // Sự kiện nhấn giữ để XÓA
                              onLongPress: () => _confirmDelete(
                                context,
                                transaction.id!,
                                transaction.title,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
