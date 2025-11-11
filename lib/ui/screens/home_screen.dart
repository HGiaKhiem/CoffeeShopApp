import 'package:flutter/material.dart';
import 'package:flutter_coffee_shop_app/controllers/home_controller.dart';
import 'package:flutter_coffee_shop_app/entities/entities_library.dart';
import 'package:flutter_coffee_shop_app/ui/screens/introduction_screen.dart';
import 'package:flutter_coffee_shop_app/ui/screens/qr_scan_screen.dart';
import 'package:flutter_coffee_shop_app/ui/widgets/widgets.dart';
import 'package:flutter_coffee_shop_app/ui/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_coffee_shop_app/ui/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _supabase = Supabase.instance.client;

  List<Coffee> _allCoffees = [];
  List<LoaiMon> _loaiMons = [];
  List<Coffee> _displayedCoffees = [];

  bool _isLoading = true;
  int? _selectedCategoryId;
  String _searchQuery = '';

  int? _idBan;
  int? _idKhach;
  String? _tenKhach;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();

    final session = _supabase.auth.currentSession;
    if (session != null) {
      _loadInitData();
    }

    _supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        debugPrint('✅ Supabase user đã đăng nhập, reload Home');
        _loadInitData();
      } else if (event == AuthChangeEvent.signedOut) {
        debugPrint('🚪 Supabase user đã đăng xuất, reset về khách vãng lai');
        setState(() {
          _idKhach = null;
          _tenKhach = 'Khách tại bàn ${_idBan ?? 1}';
          _avatarUrl =
              'https://rubeafovywlrgxblfmlr.supabase.co/storage/v1/object/public/avatar/avatar.png';
        });
      }
    });
  }

  /// ✅ Load dữ liệu: bàn + khách + danh sách món
  Future<void> _loadInitData() async {
    final prefs = await SharedPreferences.getInstance();
    _idBan = prefs.getInt('id_ban');

    // 🟢 Nếu user đã đăng nhập Supabase
    final currentUser = _supabase.auth.currentUser;

    if (currentUser != null) {
      try {
        final khach = await _supabase
            .from('khachhang')
            .select('id_khachhang, tenkh, avatarurl')
            .eq('UID', currentUser.id)
            .maybeSingle();

        if (khach != null) {
          _idKhach = khach['id_khachhang'] as int?;
          _tenKhach = khach['tenkh'] ?? 'Khách hàng';
          _avatarUrl = khach['avatarurl'] ??
              'https://rubeafovywlrgxblfmlr.supabase.co/storage/v1/object/public/avatar/avatar.png';

          await prefs.setInt('id_khachhang', _idKhach!);
        } else {
          _tenKhach = 'Khách tại bàn $_idBan';
          _avatarUrl =
              'https://rubeafovywlrgxblfmlr.supabase.co/storage/v1/object/public/avatar/avatar.png';
        }
      } catch (e) {
        debugPrint('❌ Lỗi khi tải thông tin khách: $e');
        _tenKhach = 'Khách tại bàn $_idBan';
        _avatarUrl =
            'https://rubeafovywlrgxblfmlr.supabase.co/storage/v1/object/public/avatar/avatar.png';
      }
    } else {
      // 🟠 Nếu chưa đăng nhập (khách vãng lai)
      _idKhach = prefs.getInt('id_khachhang');
      _tenKhach = 'Khách tại bàn $_idBan';
      _avatarUrl =
          'https://rubeafovywlrgxblfmlr.supabase.co/storage/v1/object/public/avatar/avatar.png';
    }

    // 🧾 Load danh sách món và loại món
    final coffees = await HomeController.getAllCoffees();
    final loaiMons = await HomeController.getAllLoaiMon();

    setState(() {
      _allCoffees = coffees;
      _loaiMons = loaiMons;
      _displayedCoffees = coffees;
      _isLoading = false;
    });

    debugPrint('👤 Đã load: $_tenKhach');
  }

  void _applyFilters() {
    List<Coffee> filtered = _allCoffees;
    if (_selectedCategoryId != null) {
      filtered =
          HomeController.filterByCategory(filtered, _selectedCategoryId!);
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 20),
                    sliver: SliverToBoxAdapter(
                      child: _buildAppBar(),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 20),
                    sliver: SliverToBoxAdapter(
                      child: SizedBox(
                        height: 48,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _loaiMons.length,
                          itemBuilder: (context, index) {
                            final loai = _loaiMons[index];
                            final isActive =
                                _selectedCategoryId == loai.id_loaimon;
                            return Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: ChoiceChip(
                                label: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  child: Text(
                                    loai.tenloaimon,
                                    style: isActive
                                        ? Apptheme.chipActive
                                        : Apptheme.chipInactive,
                                  ),
                                ),
                                selected: isActive,
                                selectedColor:
                                    Apptheme.accentColor.withOpacity(0.25),
                                backgroundColor:
                                    Apptheme.cardChipBackgroundColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                  side: BorderSide(
                                    color: isActive
                                        ? Apptheme.accentColor
                                        : Apptheme.gray3Color,
                                  ),
                                ),
                                onSelected: (_) =>
                                    _onCategorySelected(loai.id_loaimon),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 20),
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
                                      padding:
                                          const EdgeInsets.only(bottom: 15),
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

      // Nút quét QR
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

      bottomNavigationBar: CustomNavBar(idBan: _idBan ?? 1),
    );
  }

  /// 🧭 Custom AppBar hiển thị thông tin khách + bàn
  Widget _buildAppBar() {
    final user = _supabase.auth.currentUser; // 👈 Lấy user hiện tại
    final email = user?.email;
    final uid = user?.id;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
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

        // 🔹 Nếu user đăng nhập rồi → hiển thị thông tin thật
        InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () async {
            final updated = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
            if (updated == true) {
              _loadInitData(); // refresh lại khi profile thay đổi
            }
          },
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(23),
                child: Image.network(
                  // Nếu đã đăng nhập thì ưu tiên ảnh Supabase DB
                  user != null
                      ? (_avatarUrl ??
                          'https://rubeafovywlrgxblfmlr.supabase.co/storage/v1/object/public/avatar/avatar.png')
                      : 'https://rubeafovywlrgxblfmlr.supabase.co/storage/v1/object/public/avatar/avatar.png',
                  height: 45,
                  width: 45,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),

              // ✅ Nếu có user thì lấy tên trong DB / email, không thì “Khách tại bàn”
              Text(
                user != null
                    ? (_tenKhach ?? email ?? 'Người dùng')
                    : 'Khách tại bàn $_idBan',
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
  }
}
