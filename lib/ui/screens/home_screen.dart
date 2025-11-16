import 'package:flutter/material.dart';
import 'package:flutter_coffee_shop_app/controllers/home_controller.dart';
import 'package:flutter_coffee_shop_app/entities/entities_library.dart';
import 'package:flutter_coffee_shop_app/ui/theme/app_theme.dart';
import 'package:flutter_coffee_shop_app/ui/widgets/widgets.dart';
import 'package:flutter_coffee_shop_app/ui/screens/profile_screen.dart';
import 'package:flutter_coffee_shop_app/ui/screens/qr_scan_screen.dart';
import 'package:flutter_coffee_shop_app/ui/screens/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;

  List<Coffee> _allCoffees = [];
  List<Coffee> _filteredCoffees = [];
  List<LoaiMon> _loaiMons = [];

  bool _loading = true;
  String _search = '';
  int? _selectedLoai;

  int? _idBan;
  int? _idKhach;
  String? _tenKhach;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();

    // Chờ auth web load
    Future.delayed(const Duration(milliseconds: 300), () {
      _loadAll();
    });

    // Reload khi login/logout
    supabase.auth.onAuthStateChange.listen((event) {
      _loadAll();
    });
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);

    // Lấy id_ban từ local
    final prefs = await SharedPreferences.getInstance();
    _idBan = prefs.getInt('id_ban') ?? 1;

    // Lấy user hiện tại
    final user = supabase.auth.currentUser;

    if (user != null) {
      final kh = await HomeController.getCurrentCustomer();
      if (kh != null) {
        _idKhach = kh.id_khachhang;
        _tenKhach = kh.tenkh;
        _avatarUrl = kh.avatarURL;
        prefs.setInt('id_khachhang', _idKhach!);
      } else {
        _tenKhach = "Khách tại bàn $_idBan";
        _avatarUrl =
            "https://rubeafovywlrgxblfmlr.supabase.co/storage/v1/object/public/avatar/avatar.png";
      }
    } else {
      _tenKhach = "Khách tại bàn $_idBan";
      _avatarUrl =
          "https://rubeafovywlrgxblfmlr.supabase.co/storage/v1/object/public/avatar/avatar.png";

      _idKhach = prefs.getInt('id_khachhang');
    }

    // Load dữ liệu menu
    final mon = await HomeController.getAllCoffees();
    final loai = await HomeController.getAllLoaiMon();

    setState(() {
      _allCoffees = mon;
      _filteredCoffees = mon;
      _loaiMons = loai;
      _loading = false;
    });
  }

  void _filter() {
    List<Coffee> list = _allCoffees;

    if (_selectedLoai != null) {
      list = list.where((c) => c.id_loaimon == _selectedLoai).toList();
    }
    if (_search.isNotEmpty) {
      list = HomeController.searchCoffees(list, _search);
    }

    setState(() => _filteredCoffees = list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Apptheme.backgroundColor,
      extendBody: true,

      // ========================= BODY =========================
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.brown))
            : CustomScrollView(
                slivers: [
                  // AppBar custom
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 18),
                      child: _buildAppBar(),
                    ),
                  ),

                  // Title
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Discover Your", style: Apptheme.tileLarge),
                          Text("Perfect Coffee", style: Apptheme.tileLarge),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // Search
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: SearchWidget(
                        onChanged: (v) {
                          _search = v;
                          _filter();
                        },
                      ),
                    ),
                  ),

                  // Category chips
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 20),
                      child: SizedBox(
                        height: 48,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _loaiMons.length,
                          itemBuilder: (context, i) {
                            final loai = _loaiMons[i];
                            final active = loai.id_loaimon == _selectedLoai;

                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: ChoiceChip(
                                selected: active,
                                label: Text(loai.tenloaimon,
                                    style: active
                                        ? Apptheme.chipActive
                                        : Apptheme.chipInactive),
                                selectedColor:
                                    Apptheme.accentColor.withOpacity(0.25),
                                backgroundColor:
                                    Apptheme.cardChipBackgroundColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                  side: BorderSide(
                                      color: active
                                          ? Apptheme.accentColor
                                          : Apptheme.gray3Color),
                                ),
                                onSelected: (_) {
                                  setState(() {
                                    _selectedLoai =
                                        active ? null : loai.id_loaimon;
                                  });
                                  _filter();
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // Featured Drinks
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Featured Drinks", style: Apptheme.subtileLarge),
                          const SizedBox(height: 15),
                          SizedBox(
                            height: 260,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _filteredCoffees.length,
                              itemBuilder: (_, i) {
                                final coffee = _filteredCoffees[i];
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

                  // Special for You
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 20),
                      child: _filteredCoffees.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(30),
                                child: Text("Không có món phù hợp",
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 16)),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _filteredCoffees.length,
                              itemBuilder: (_, i) {
                                final coffee = _filteredCoffees[i];
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
                    ),
                  ),
                ],
              ),
      ),

      // ================= FLOATING QR BUTTON ==================
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 6),
        child: FloatingActionButton(
          backgroundColor: Colors.brown,
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const QrScanScreen()));
          },
          child: const Icon(Icons.qr_code_scanner_rounded,
              color: Colors.white, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: CustomNavBar(idBan: _idBan ?? 1),
    );
  }

  // ===========================================================
  // 🔥 CUSTOM APP BAR (hiển thị avatar + tên khách)
  // ===========================================================

  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Nút menu
        CustomIconButton(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const IntroductionScreen()),
            );
          },
          width: 50,
          height: 50,
          child: const Icon(Icons.menu, color: Colors.white, size: 28),
        ),

        // Avatar + Tên
        InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () async {
            final updated = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
            if (updated == true) _loadAll();
          },
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  _avatarUrl ??
                      "https://rubeafovywlrgxblfmlr.supabase.co/storage/v1/object/public/avatar/avatar.png",
                  width: 45,
                  height: 45,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _tenKhach ?? "Khách tại bàn $_idBan",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
