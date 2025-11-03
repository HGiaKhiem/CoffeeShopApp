import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Apptheme {
  static const Color backgroundColor = Color(0xff1A120B); // Màu nâu gỗ đậm
  static const Color primaryColor = Color(0xff8B4513); // Màu nâu cà phê đậm
  static const Color accentColor = Color(0xffD4A017); // Màu vàng caramel
  static const Color gray1Color = Color(0xff4A3728); // Nâu xám đậm
  static const Color gray2Color = Color(0xff5C4836); // Nâu xám trung
  static const Color gray3Color = Color(0xff7A6856); // Nâu xám nhạt
  static const Color iconColor = Color(0xff6B4E31); // Nâu gỗ trung tính
  static const Color iconActiveColor = Color(0xffE8B923); // Vàng caramel sáng

  // Page Indicator
  static const Color indicatorInactiveColor = Color(0xff6B4E31);
  static const Color indicatorActiveColor = Color(0xffE8B923);
  static TextStyle introtile = GoogleFonts.roboto(
    color: Colors.white,
    fontSize: 30,
    fontWeight: FontWeight.bold,
  );
  static TextStyle introSubtile = GoogleFonts.roboto(
    color: const Color(0xffB8A89A),
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  // Reviews Ratings
  static const Color reviewIconColor = Color(0xffB8A89A);
  static TextStyle reviewRatting = GoogleFonts.roboto(
    color: Colors.white,
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );

  // Style
  static TextStyle tileLarge = GoogleFonts.roboto(
    color: Colors.white,
    fontSize: 30,
    fontWeight: FontWeight.bold,
  );
  static TextStyle subtileLarge = GoogleFonts.roboto(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
  // Search
  static const Color searchCursorColor = Color(0xff5C4836);
  static const Color searchBacgroundColor = Color(0xff2C1F14);
  static TextStyle searchTextStyle = GoogleFonts.roboto(
    color: Color(0xff5C4836),
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
  // Carda Large TextStyle
  static const Color cardChipBackgroundColor = Color(0xff1F160F);
  static TextStyle cardChipTextStyle = GoogleFonts.roboto(
    color: const Color(0xffB8A89A),
    fontSize: 12,
    fontWeight: FontWeight.w800,
  );
  static TextStyle cardTitleLarge = GoogleFonts.roboto(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.w800,
  );
  static TextStyle cardTitleMedium = GoogleFonts.roboto(
    color: Colors.white,
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );
  static TextStyle cardTitleSmall = GoogleFonts.roboto(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
  static TextStyle cardSubtitleLarge = GoogleFonts.roboto(
    color: const Color(0xffB8A89A),
    fontSize: 14,
    fontWeight: FontWeight.w800,
  );
  static TextStyle cardSubtitleMedium = GoogleFonts.roboto(
    color: const Color(0xff7A6856),
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );
  static TextStyle cardSubtitleSmall = GoogleFonts.roboto(
    color: const Color(0xff7A6856),
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  // Price TextStyle
  static TextStyle priceCurrencySmall = GoogleFonts.roboto(
    color: const Color(0xffD4A017),
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );
  static TextStyle priceValueSmall = GoogleFonts.roboto(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );
  static TextStyle priceCurrencyLarge = GoogleFonts.roboto(
    color: const Color(0xffD4A017),
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  static TextStyle priceTitleLarge = GoogleFonts.roboto(
    color: const Color(0xffA89B8D),
    fontSize: 18,
    fontWeight: FontWeight.w400,
  );
  static TextStyle priceValueLarge = GoogleFonts.roboto(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  // Description TextStyle
  static TextStyle descriptionTitle = GoogleFonts.roboto(
    color: const Color(0xffA89B8D),
    fontSize: 18,
    fontWeight: FontWeight.w800,
  );
  static TextStyle descriptionContent = GoogleFonts.roboto(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  static TextStyle descriptionReadMore = GoogleFonts.roboto(
    color: const Color(0xffD4A017),
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  // Chips TextStyle
  static TextStyle chipActive = GoogleFonts.roboto(
    color: const Color(0xffD4A017),
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );
  static TextStyle chipInactive = GoogleFonts.roboto(
    color: const Color(0xff4A3728),
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  // Buttons Style
  static const Color buttonBackground1Color = Color(0xff8B4513);
  static const Color buttonBackground2Color = Color(0xff2C1F14);
  static const Color buttonBorderColor = Color(0xffD4A017);
  static TextStyle buttonTextStyle = GoogleFonts.roboto(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w800,
  );
  static TextStyle buttonActiveTextStyle = GoogleFonts.roboto(
    color: const Color(0xffD4A017),
    fontSize: 18,
    fontWeight: FontWeight.w800,
  );
  static TextStyle buttonInactiveTextStyle = GoogleFonts.roboto(
    color: const Color(0xffA89B8D),
    fontSize: 18,
    fontWeight: FontWeight.w800,
  );
}
