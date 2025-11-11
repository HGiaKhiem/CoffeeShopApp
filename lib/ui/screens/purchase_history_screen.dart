import 'package:flutter/material.dart';
import 'package:flutter_coffee_shop_app/controllers/purchase_history_controller.dart';
import 'package:flutter_coffee_shop_app/ui/theme/app_theme.dart';

class PurchaseHistoryScreen extends StatefulWidget {
  final int idKhach;
  const PurchaseHistoryScreen({Key? key, required this.idKhach})
      : super(key: key);

  @override
  State<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen>
    with SingleTickerProviderStateMixin {
  final controller = PurchaseHistoryController();
  List<Map<String, dynamic>> _history = [];
  bool _loading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await controller.loadHistory(widget.idKhach);
    setState(() {
      _history = data;
      _loading = false;
    });
  }

  List<Map<String, dynamic>> get _rated => _history
      .where((e) => ((e['danhgia_mon'] as List?)?.isNotEmpty ?? false))
      .toList();

  /// 🟤 Hiển thị dialog đánh giá món
  void _showFeedbackDialog(Map<String, dynamic> item) {
    final feedback = (item['danhgia_mon'] as List?)?.firstOrNull;
    final TextEditingController commentCtrl =
        TextEditingController(text: feedback?['nhanxet'] ?? '');
    int rating = feedback?['sosao'] ?? 0;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Đánh giá món'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                return IconButton(
                  icon: Icon(
                    i < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 30,
                  ),
                  onPressed: () {
                    setState(() => rating = i + 1);
                    Navigator.pop(context);
                    _showFeedbackDialog(item
                      ..['danhgia_mon'] = [
                        {'sosao': rating, 'nhanxet': commentCtrl.text}
                      ]);
                  },
                );
              }),
            ),
            TextField(
              controller: commentCtrl,
              decoration: const InputDecoration(
                labelText: 'Nhận xét của bạn...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
            onPressed: () async {
              final success = await controller.sendFeedback(
                idLichSu: item['id_lichsu'],
                idKhachHang: item['id_khachhang'],
                idMon: item['id_mon'],
                rating: rating,
                comment: commentCtrl.text,
              );
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Gửi đánh giá thành công!')),
                );
                Navigator.pop(context);
                _loadData();
              }
            },
            child: const Text('Gửi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allTab = _buildList(_history);
    final ratedTab = _buildList(_rated);

    return Scaffold(
      backgroundColor: Apptheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Lịch sử mua hàng'),
        backgroundColor: Colors.brown,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.receipt_long), text: "Tất cả"),
            Tab(icon: Icon(Icons.star), text: "Đã đánh giá"),
          ],
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.brown),
            )
          : TabBarView(
              controller: _tabController,
              children: [allTab, ratedTab],
            ),
    );
  }

  /// 🟢 Danh sách lịch sử mua hàng
  Widget _buildList(List<Map<String, dynamic>> list) {
    if (list.isEmpty) {
      return const Center(
        child: Text(
          'Không có dữ liệu.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: Colors.brown,
      backgroundColor: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          final mon = item['mon'];
          final don = item['donhang'];
          final feedback = (item['danhgia_mon'] as List?)?.firstOrNull;

          final imgUrl = mon?['HinhAnh'] ?? '';
          final sosao = feedback?['sosao'];
          final nhanxet = feedback?['nhanxet'];
          final date = DateTime.parse(item['ngaymua']).toLocal();

          return Card(
            color: Colors.white.withOpacity(0.08),
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imgUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.local_cafe,
                    color: Colors.white54,
                    size: 40,
                  ),
                ),
              ),
              title: Text(
                mon?['tenmon'] ?? 'Không rõ món',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Giá: ${item['giaban']}₫',
                        style: const TextStyle(color: Colors.white70)),
                    Text('Số lượng: ${item['soluong']}',
                        style: const TextStyle(color: Colors.white70)),
                    Text(
                      'Ngày mua: ${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    Text('Trạng thái: ${don?['trangthai']}',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12)),
                    if (sosao != null)
                      Row(
                        children: List.generate(5, (i) {
                          return Icon(
                            i < sosao ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 18,
                          );
                        }),
                      ),
                    if (nhanxet != null && nhanxet.isNotEmpty)
                      Text(
                        '“$nhanxet”',
                        style: const TextStyle(
                            color: Colors.white70, fontStyle: FontStyle.italic),
                      ),
                  ],
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.rate_review, color: Colors.amber),
                tooltip: 'Đánh giá món này',
                onPressed: () => _showFeedbackDialog(item),
              ),
            ),
          );
        },
      ),
    );
  }
}
