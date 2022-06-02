

import 'package:flutter/material.dart';

typedef ReturnChild = Widget Function(BuildContext buildContext,Function closeTooltip);

typedef StateGetter = Widget Function( BuildContext buildContext , Function(Function) state);

class TextType{

  double size;
  FontWeight fontWeight;
  TextType(this.size,this.fontWeight);

  static final TextType textTypeTitle =TextType(27,FontWeight.w800);
  static final TextType textTypeSubtitle =TextType(20,FontWeight.w700);
  static final TextType textTypeNormal =TextType(15,FontWeight.w600);
  static final TextType textTypeSubNormal =TextType(12,FontWeight.w400);
  static final TextType textTypeSubMiniscule =TextType(9,FontWeight.w300);
  static final TextType textTypeGigant =TextType(50,FontWeight.w900);

}

enum FABAction{
  AddTask,
}

enum Interest{
  Brain,
  Energy,
  Health
}

enum ProgressiveActionDifficulty{
  Easy,Medium,Hard,
}


