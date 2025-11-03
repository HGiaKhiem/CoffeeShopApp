import 'package:flutter/material.dart';
import 'package:flutter_coffee_shop_app/ui/screens/screens.dart';
import 'package:flutter_coffee_shop_app/ui/theme/app_theme.dart';
import 'package:flutter_coffee_shop_app/ui/widgets/widgets.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

// Định nghĩa class Introduction
class Introduction {
  final String title;
  final String subtitle;
  final String imageUrl;

  Introduction({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  });
}

class IntroductionScreen extends StatelessWidget {
  const IntroductionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final introductionItems = [
      Introduction(
        title: 'Rise and Savor the Coffee',
        subtitle: 'Experience the aroma and flavor like never before.',
        imageUrl: 'https://i.imgur.com/f1ZkmgC.jpg',
      ),
      Introduction(
        title: 'Savor the Moment with Our Coffee',
        subtitle: 'Indulge in our artisanal blends and taste the difference.',
        imageUrl: 'https://i.imgur.com/IjY028x.jpg',
      ),
      Introduction(
        title: 'Elevate Your Coffee Experience',
        subtitle:
            'Discover a world of rich, bold flavors with our premium roasts.',
        imageUrl: 'https://i.imgur.com/nnroE8z.jpg',
      ),
    ];
    final int itemCount = introductionItems.length;

    PageController controller = PageController();
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: controller,
            physics: const ClampingScrollPhysics(),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final item = introductionItems[index];
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error),
                    ),
                  ),
                  Container(color: Apptheme.backgroundColor.withOpacity(0.7)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    alignment: const Alignment(0, 0.5),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.title,
                          style: Apptheme.introtile,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          item.subtitle,
                          style: Apptheme.introSubtile,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          // PageIndicator
          Container(
            alignment: const Alignment(0, 0.65),
            child: SmoothPageIndicator(
              controller: controller,
              count: itemCount,
              effect: const ExpandingDotsEffect(
                activeDotColor: Apptheme.indicatorActiveColor,
                dotColor: Apptheme.indicatorInactiveColor,
                dotHeight: 5,
                dotWidth: 10,
              ),
            ),
          ),
          // Get Start Button
          Container(
            alignment: const Alignment(0, 0.85),
            child: CustomFilledButton(
              width: 136,
              height: 54,
              color: Apptheme.buttonBackground2Color,
              borderRadius: 16,
              onTap: () {
                final user = Supabase.instance.client.auth.currentUser;

                if (user == null) {
                  // chưa đăng nhập → chuyển sang LoginScreen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                } else {
                  // Đã đăng nhập → chuyển sang HomeScreen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                }
              },
              child: Text('Bắt đầu', style: Apptheme.cardTitleSmall),
            ),
          ),
        ],
      ),
    );
  }
}
