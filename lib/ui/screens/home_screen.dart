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
  List<Coffee> _specialCoffees = [];
  List<Coffee> _topLiked = [];
  List<Coffee> _filtered = [];
  List<LoaiMon> _loaiMons = [];

  String _search = "";
  int? _selectedLoai;
  bool _loading = true;

  int? _idBan;
  int? _idKhach;
  String? _tenKhach;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadInitial();
    supabase.auth.onAuthStateChange.listen((_) => _loadInitial());
  }

  Future<void> _loadInitial() async {
    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();
    _idBan = prefs.getInt("id_ban") ?? 1;

    final user = supabase.auth.currentUser;

    // ====== Khách hàng ======
    if (user != null) {
      final kh = await HomeController.getCurrentCustomer();
      if (kh != null) {
        _idKhach = kh.id_khachhang;
        _tenKhach = kh.tenkh;
        _avatarUrl = kh.avatarURL;
        prefs.setInt("id_khachhang", _idKhach!);
      } else {
        _tenKhach = "Khách tại bàn $_idBan";
        _avatarUrl =
            "https://rubeafovywlrgxblfmlr.supabase.co/storage/v1/object/public/avatar/avatar.png";
      }
    } else {
      _idKhach = prefs.getInt("id_khachhang");
      _tenKhach = "Khách tại bàn $_idBan";
      _avatarUrl =
          "https://rubeafovywlrgxblfmlr.supabase.co/storage/v1/object/public/avatar/avatar.png";
    }

    // ====== Menu ======
    final coffees = await HomeController.getAllCoffees();
    final loai = await HomeController.getAllLoaiMon();
    final top = await HomeController.getTopLikedDrinks();

    _specialCoffees = HomeController.getSpecialCoffees(coffees);

    setState(() {
      _allCoffees = coffees;
      _filtered = coffees;
      _loaiMons = loai;
      _topLiked = top;
      _loading = false;
    });
  }

  void _applyFilter() {
    List<Coffee> list = _allCoffees;

    if (_selectedLoai != null) {
      list = list.where((c) => c.id_loaimon == _selectedLoai).toList();
    }

    if (_search.isNotEmpty) {
      list = HomeController.searchCoffees(list, _search);
    }

    setState(() => _filtered = list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Apptheme.backgroundColor,
      extendBody: true,

      // BODY
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.brown))
            : CustomScrollView(
                slivers: [
                  // AppBar
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
                        onChanged: (value) {
                          _search = value;
                          _applyFilter();
                        },
                      ),
                    ),
                  ),

                  // Category Chips
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 22, right: 22, top: 10),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 48,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 10),
                              itemCount: _loaiMons.length,
                              itemBuilder: (context, i) {
                                final loai = _loaiMons[i];
                                final active = loai.id_loaimon == _selectedLoai;

                                return ChoiceChip(
                                  selected: active,
                                  labelPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 2),
                                  label: Text(
                                    loai.tenloaimon,
                                    style: active
                                        ? Apptheme.chipActive
                                        : Apptheme.chipInactive,
                                  ),
                                  selectedColor:
                                      Apptheme.accentColor.withOpacity(0.25),
                                  backgroundColor:
                                      Apptheme.cardChipBackgroundColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                    side: BorderSide(
                                      color: active
                                          ? Apptheme.accentColor
                                          : Apptheme.gray3Color,
                                    ),
                                  ),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                  onSelected: (_) {
                                    setState(() {
                                      _selectedLoai =
                                          active ? null : loai.id_loaimon;
                                    });
                                    _applyFilter();
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                      ),
                    ),
                  ),

                  // TOP LIKE (Featured)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_topLiked.isNotEmpty)
                            Text("Top Rated Drinks",
                                style: Apptheme.subtileLarge),
                          if (_topLiked.isNotEmpty) const SizedBox(height: 10),
                          if (_topLiked.isNotEmpty)
                            SizedBox(
                              height: 260,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _topLiked.length,
                                itemBuilder: (_, i) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 15),
                                    child: VerticalCardWidget(
                                      coffee: _topLiked[i],
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

                  // “Special for You”
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _filtered.isEmpty
                                ? "Không có món phù hợp"
                                : "All Drinks",
                            style: Apptheme.subtileLarge,
                          ),
                          const SizedBox(height: 15),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _filtered.length,
                            itemBuilder: (_, i) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: HorizontalCardWidget(
                                  coffee: _filtered[i],
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

      // QR BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        child: const Icon(Icons.qr_code_scanner_rounded,
            color: Colors.white, size: 28),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const QrScanScreen()));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: CustomNavBar(idBan: _idBan ?? 1),
    );
  }

  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
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
        InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () async {
            final updated = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
            if (updated == true) _loadInitial();
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
              ),
            ],
          ),
        )
      ],
    );
  }
}
