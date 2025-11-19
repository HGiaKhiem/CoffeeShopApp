import 'package:flutter/material.dart';
import 'package:flutter_coffee_shop_app/ui/screens/order_detail_screen.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_coffee_shop_app/ui/theme/app_theme.dart';
import 'package:flutter_coffee_shop_app/ui/screens/home_screen.dart';
import 'package:flutter_coffee_shop_app/ui/screens/cart_screen.dart';
import 'package:flutter_coffee_shop_app/ui/screens/qr_scan_screen.dart';
import 'package:flutter_coffee_shop_app/ui/screens/voucher_screen.dart';

final supabase = Supabase.instance.client;

class CustomNavBar extends StatefulWidget {
  final int idBan;

  const CustomNavBar({
    Key? key,
    required this.idBan,
  }) : super(key: key);

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  int _selectedIndex = 0;
  int? _idKhach;
  bool _loadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadIdKhachFromSupabase();
  }

  Future<void> _loadIdKhachFromSupabase() async {
    try {
      await supabase.auth.refreshSession();
      await Future.delayed(const Duration(milliseconds: 400));

      final uid = supabase.auth.currentUser?.id;
      if (uid == null) {
        print('⚠️ UID vẫn null → chưa đăng nhập');
        setState(() {
          _loadingUser = false;
          _idKhach = null;
        });
        return;
      }

      print('🔍 Đang lấy id_khachhang cho UID: $uid');
      final kh = await supabase
          .from('khachhang')
          .select('id_khachhang')
          .eq('UID', uid)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _idKhach = kh != null ? (kh['id_khachhang'] as num).toInt() : null;
          _loadingUser = false;
        });
      }

      print('✅ ID khách hiện tại: $_idKhach');
    } catch (e) {
      if (mounted) {
        setState(() {
          _idKhach = null;
          _loadingUser = false;
        });
      }
      print('❌ Lỗi load id khách: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    const selectedColor = Apptheme.iconActiveColor;
    const unSelectedColor = Apptheme.iconColor;

    if (_loadingUser) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.brown),
      );
    }

    return StylishBottomBar(
      backgroundColor: const Color(0xff0D1015),
      items: [
        BottomBarItem(
          icon: const Icon(Icons.home),
          selectedIcon: const Icon(Icons.home),
          selectedColor: selectedColor,
          unSelectedColor: unSelectedColor,
          title: const Text('Trang chủ'),
        ),
        BottomBarItem(
          icon: const Icon(Icons.shopping_bag_rounded),
          selectedIcon: const Icon(Icons.shopping_bag_rounded),
          selectedColor: selectedColor,
          unSelectedColor: unSelectedColor,
          title: const Text('Giỏ hàng'),
        ),
        BottomBarItem(
          icon: const Icon(Icons.qr_code_2),
          selectedIcon: const Icon(Icons.qr_code_2),
          selectedColor: selectedColor,
          unSelectedColor: unSelectedColor,
          title: const Text('Quét mã'),
        ),
        BottomBarItem(
          icon: const Icon(Icons.card_giftcard),
          selectedIcon: const Icon(Icons.card_giftcard),
          selectedColor: selectedColor,
          unSelectedColor: unSelectedColor,
          title: const Text('Voucher'),
        ),
      ],
      hasNotch: true,
      fabLocation: StylishBarFabLocation.center,
      currentIndex: _selectedIndex,
      option: AnimatedBarOptions(
        iconSize: 26,
        barAnimation: BarAnimation.fade,
        iconStyle: IconStyle.simple,
        opacity: 0.4,
      ),
      onTap: (index) {
        setState(() => _selectedIndex = index);

        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
            break;

          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CartScreen(idBan: widget.idBan),
              ),
            );
            break;

          case 2:
            if (_idKhach == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("⚠️ Bạn chưa đăng nhập!"),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderDetailScreen(
                  idBan: widget.idBan,
                ),
              ),
            );
            break;

          case 3:
            if (_idKhach == null) {
              print('⚠️ Không có id_khach → chưa đăng nhập!');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('⚠️ Vui lòng đăng nhập để xem voucher'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }

            print('➡️ Mở VoucherScreen với id_khach: $_idKhach');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VoucherScreen(idKhach: _idKhach!),
              ),
            );
            break;
        }
      },
    );
  }
}
