import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_coffee_shop_app/ui/theme/app_theme.dart';

class SearchWidget extends StatelessWidget {
  final ValueChanged<String>? onChanged; // callback khi gõ
  final VoidCallback? onTapSearch; //callback khi bấm icon (tùy chọn)

  const SearchWidget({
    Key? key,
    this.onChanged,
    this.onTapSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 20),
      height: 60,
      decoration: const BoxDecoration(
        color: Apptheme.searchBacgroundColor,
        borderRadius: BorderRadiusDirectional.all(Radius.circular(15)),
      ),
      child: Row(
        children: [
          // 🔍 Nút icon search
          IconButton(
            onPressed: onTapSearch ?? () {},
            icon: const Icon(
              CupertinoIcons.search,
              color: Apptheme.iconColor,
            ),
          ),

          Expanded(
            child: TextField(
              cursorColor: Apptheme.searchCursorColor,
              style: Apptheme.searchTextStyle,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Find your coffee...',
                hintStyle: Apptheme.searchTextStyle,
              ),
              onChanged: onChanged, // gọi callback mỗi khi gõ
            ),
          ),
        ],
      ),
    );
  }
}
