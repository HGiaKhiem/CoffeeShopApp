import 'package:flutter/material.dart';
import 'package:flutter_coffee_shop_app/controllers/home_controller.dart';
import 'package:flutter_coffee_shop_app/entities/entities_library.dart';
import 'package:flutter_coffee_shop_app/ui/screens/introduction_screen.dart';
import 'package:flutter_coffee_shop_app/ui/screens/qr_scan_screen.dart';
import 'package:flutter_coffee_shop_app/ui/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/widgets.dart';
import 'package:flutter_coffee_shop_app/ui/screens/screens.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Coffee> _allCoffees = [];
  List<LoaiMon> _loaiMons = [];
  List<Coffee> _displayedCoffees = [];

  bool _isLoading = true;
  int? _selectedCategoryId;
  String _searchQuery = '';

  int? _idBan;
  int? _idKhach;

  @override
  void initState() {
    super.initState();
    _loadInitData();
  }

  /// ✅ Load dữ liệu: bàn + khách + danh sách món
  Future<void> _loadInitData() async {
    final prefs = await SharedPreferences.getInstance();
    _idBan = prefs.getInt('id_ban');
    _idKhach = prefs.getInt('id_khachhang');

    final coffees = await HomeController.getAllCoffees();
    final loaiMons = await HomeController.getAllLoaiMon();

    setState(() {
      _allCoffees = coffees;
      _loaiMons = loaiMons;
      _displayedCoffees = coffees;
      _isLoading = false;
    });
  }

  void _applyFilters() {
    List<Coffee> filtered = _allCoffees;
    if (_selectedCategoryId != null) {
      filtered = HomeController.filterByCategory(filtered, _selectedCategoryId!);
    }
    if (_searchQuery.isNotEmpty) {
      filtered = HomeController.searchCoffees(filtered, _searchQuery);
    }
    setState(() => _displayedCoffees = filtered);
  }

  void _onCategorySelected(int idLoai) {
    setState(() {
      if (_selectedCategoryId == idLoai) {
        _selectedCategoryId = null;
      } else {
        _selectedCategoryId = idLoai;
      }
    });
    _applyFilters();
  }

  void _onSearchChanged(String value) {
    _searchQuery = value;
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Apptheme.backgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  // 🧱 AppBar
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                    sliver: SliverToBoxAdapter(
                      child: HomeCustomAppBar(
                        idBan: _idBan,
                        idKhach: _idKhach,
                      ),
                    ),
                  ),

                  // 🧱 Tiêu đề
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Discover Your', style: Apptheme.tileLarge),
                          Text('Perfect Coffee', style: Apptheme.tileLarge),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // 🔍 Thanh tìm kiếm
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    sliver: SliverToBoxAdapter(
                      child: SearchWidget(onChanged: _onSearchChanged),
                    ),
                  ),

                  // ☕️ Loại món
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                    sliver: SliverToBoxAdapter(
                      child: SizedBox(
                        height: 48,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _loaiMons.length,
                          itemBuilder: (context, index) {
                            final loai = _loaiMons[index];
                            final isActive = _selectedCategoryId == loai.id_loaimon;
                            return Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: ChoiceChip(
                                label: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  child: Text(
                                    loai.tenloaimon,
                                    style: isActive
                                        ? Apptheme.chipActive
                                        : Apptheme.chipInactive,
                                  ),
                                ),
                                selected: isActive,
                                selectedColor: Apptheme.accentColor.withOpacity(0.25),
                                backgroundColor: Apptheme.cardChipBackgroundColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                  side: BorderSide(
                                    color: isActive
                                        ? Apptheme.accentColor
                                        : Apptheme.gray3Color,
                                  ),
                                ),
                                onSelected: (_) => _onCategorySelected(loai.id_loaimon),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // 🧾 Featured Drinks
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Featured Drinks', style: Apptheme.subtileLarge),
                          const SizedBox(height: 15),
                          SizedBox(
                            height: 260,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _displayedCoffees.length,
                              itemBuilder: (context, index) {
                                final coffee = _displayedCoffees[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 15),
                                  child: VerticalCardWidget(
                                    coffee: coffee,
                                    idBan: _idBan,
                                    idKhachHang: _idKhach,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 🧾 Special for You
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Special for You', style: Apptheme.subtileLarge),
                          const SizedBox(height: 15),
                          _displayedCoffees.isEmpty
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 50),
                                    child: Text(
                                      'Không có món phù hợp',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: _displayedCoffees.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final coffee = _displayedCoffees[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 15),
                                      child: HorizontalCardWidget(
                                        coffee: coffee,
                                        idBan: _idBan,
                                        idKhachHang: _idKhach,
                                      ),
                                    );
                                  },
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),

      // QR Scan FAB
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 8),
        child: FloatingActionButton(
          backgroundColor: Colors.brown,
          elevation: 5,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QrScanScreen()),
            );
          },
          child: const Icon(
            Icons.qr_code_scanner_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomNavBar(
        idBan: _idBan ?? 1,
        idKhach: _idKhach ?? 1,
      ),
    );
  }
}

/// 🧭 Custom AppBar hiển thị thông tin khách + bàn
class HomeCustomAppBar extends StatelessWidget {
  final int? idBan;
  final int? idKhach;

  const HomeCustomAppBar({super.key, this.idBan, this.idKhach});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<KhachHang?>(
      future: HomeController.getCurrentCustomer(),
      builder: (context, snapshot) {
        final customer = snapshot.data;
        final imageUrl = customer?.avatarURL ??
            'https://rubeafovywlrgxblfmlr.supabase.co/storage/v1/object/public/avatar/avatar.png';
        final tenKhach = customer?.tenkh ??
            (idKhach != null ? 'Khách tại bàn $idBan' : 'Khách hàng');

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Nút menu
            CustomIconButton(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const IntroductionScreen(),
                  ),
                );
              },
              width: 50,
              height: 50,
              child: const Icon(
                Icons.menu,
                color: Apptheme.iconColor,
                size: 28,
              ),
            ),

            // Avatar + tên khách
            InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(customer: customer),
                  ),
                );
              },
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(23),
                    child: Image.network(
                      imageUrl,
                      height: 45,
                      width: 45,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.network(
                        'https://rubeafovywlrgxblfmlr.supabase.co/storage/v1/object/public/avatar/avatar.png',
                        height: 45,
                        width: 45,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    tenKhach,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
