import 'package:flutter/material.dart';
import 'package:flutter_coffee_shop_app/ui/screens/home_screen.dart';
import 'package:flutter_coffee_shop_app/ui/screens/qr_scan_screen.dart';
import 'package:flutter_coffee_shop_app/ui/theme/app_theme.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:flutter_coffee_shop_app/ui/screens/cart_screen.dart';

class CustomNavBar extends StatefulWidget {
  final int idBan;
  final int idKhach;

  const CustomNavBar({
    Key? key,
    required this.idBan,
    required this.idKhach,
  }) : super(key: key);

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    const selectedColor = Apptheme.iconActiveColor;
    const unSelectedColor = Apptheme.iconColor;

    return SizedBox(
      height: 120,
      child: StylishBottomBar(
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
            icon: const Icon(Icons.notifications),
            selectedIcon: const Icon(Icons.notifications_active),
            selectedColor: selectedColor,
            unSelectedColor: unSelectedColor,
            title: const Text('Thông báo'),
          ),
        ],
        hasNotch: true,
        fabLocation: StylishBarFabLocation.center,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);

          // 🔹 Tab 0: về Home (dùng push thay vì pushReplacement)
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }

          // 🔹 Tab 1: mở giỏ hàng (truyền idBan, idKhach)
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CartScreen(
                  idBan: widget.idBan,
                  idKhach: widget.idKhach,
                ),
              ),
            );
          }

          // 🔹 Tab 2: mở quét QR
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QrScanScreen()),
            );
          }
        },
        option: AnimatedBarOptions(
          iconSize: 25,
          barAnimation: BarAnimation.fade,
          iconStyle: IconStyle.simple,
          opacity: 0.4,
        ),
      ),
    );
  }
}
