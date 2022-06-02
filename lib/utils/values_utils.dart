
import 'dart:ui';

import '../main.dart';



class MyColors{
  static const Color color_primary = Color(0xff74b772);
  static const Color color_secondary = Color(0xffc43e3b);
  static const Color color_primary_lighter = Color(0xff9ece9b);

  static const Color color_black = Color(0xff202020);
  static const Color color_black_darker = Color(0xff161616);


  static const Color color_gray_darker = Color(0xff393939);
  static const Color color_gray_lighter = Color(0xffd6d6d6);

  static getIconTextGray(){
    return MyApp.isDarkMode?color_gray_lighter:color_gray_darker;
  }

  static getHelpColor(){
    return MyApp.isDarkMode?color_gray_darker:color_gray_lighter;
  }

}

class AssetsPath{
  static var checkboxAnimation = "assets/checkbox.flr";
  static var tick = 'assets/sounds/tick.mp3';

}