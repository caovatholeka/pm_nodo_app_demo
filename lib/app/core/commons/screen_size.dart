import 'package:flutter/material.dart';

class ScreenSize {
  late double width;
  late double height;
  late double topPadding;
  late double bottomPadding;

  ScreenSize.of(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    width = mediaQueryData.size.width;
    height = mediaQueryData.size.height;
    topPadding = mediaQueryData.padding.top;
    bottomPadding = mediaQueryData.padding.bottom;
  }
}