import 'package:flutter/material.dart';
import 'package:flutter_coffee_shop_app/ui/screens/home_screen.dart';
import 'package:flutter_coffee_shop_app/ui/screens/qr_scan_screen.dart';
import 'package:flutter_coffee_shop_app/ui/theme/app_theme.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

class CustomNavBar extends StatefulWidget {
  const CustomNavBar({Key? key}) : super(key: key);

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
            title: const Text('All'),
          ),
          BottomBarItem(
            icon: const Icon(Icons.shopping_bag_rounded),
            selectedIcon: const Icon(Icons.shopping_bag_rounded),
            selectedColor: selectedColor,
            unSelectedColor: unSelectedColor,
            title: const Text('Completed'),
          ),
          BottomBarItem(
            icon: const Icon(Icons.favorite),
            selectedIcon: const Icon(Icons.favorite),
            selectedColor: selectedColor,
            unSelectedColor: unSelectedColor,
            title: const Text('Pending'),
          ),
          BottomBarItem(
            icon: const Icon(Icons.notification_add_rounded),
            selectedIcon: const Icon(Icons.notification_add_rounded),
            selectedColor: selectedColor,
            unSelectedColor: unSelectedColor,
            title: const Text('Reminders'),
          ),
        ],
        hasNotch: true, // 🔸 bật notch để hiển thị nút giữa
        fabLocation: StylishBarFabLocation.center,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);

          // 🔹 Chuyển về Home khi chọn tab đầu tiên
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
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
