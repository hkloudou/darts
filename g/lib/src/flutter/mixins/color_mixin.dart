/*
 * Copyright (c) 2020 Pawan Kumar. All rights reserved.
 *
 *  * Licensed under the Apache License, Version 2.0 (the "License");
 *  * you may not use this file except in compliance with the License.
 *  * You may obtain a copy of the License at
 *  * http://www.apache.org/licenses/LICENSE-2.0
 *  * Unless required by applicable law or agreed to in writing, software
 *  * distributed under the License is distributed on an "AS IS" BASIS,
 *  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  * See the License for the specific language governing permissions and
 *  * limitations under the License.
 */

import 'package:flutter/material.dart';
import 'package:g/g.dart';
// import 'package:velocity_x/velocity_x.dart';

mixin GColorMixin<T> {
  late T _childToColor;

  @protected
  Color? velocityColor;

  @protected
  void setChildToColor(T child) {
    _childToColor = child;
  }

  T get white => _colorIt(child: _childToColor, color: G.white);
  T get black => _colorIt(child: _childToColor, color: G.black);

  ///Gray
  T get gray50 => _colorIt(child: _childToColor, color: G.gray50);
  T get gray100 => _colorIt(child: _childToColor, color: G.gray100);
  T get gray200 => _colorIt(child: _childToColor, color: G.gray200);
  T get gray300 => _colorIt(child: _childToColor, color: G.gray300);
  T get gray400 => _colorIt(child: _childToColor, color: G.gray400);
  T get gray500 => _colorIt(child: _childToColor, color: G.gray500);
  T get gray600 => _colorIt(child: _childToColor, color: G.gray600);
  T get gray700 => _colorIt(child: _childToColor, color: G.gray700);
  T get gray800 => _colorIt(child: _childToColor, color: G.gray800);
  T get gray900 => _colorIt(child: _childToColor, color: G.gray900);

  ///Slate
  T get slate50 => _colorIt(child: _childToColor, color: G.slate50);
  T get slate100 => _colorIt(child: _childToColor, color: G.slate100);
  T get slate200 => _colorIt(child: _childToColor, color: G.slate200);
  T get slate300 => _colorIt(child: _childToColor, color: G.slate300);
  T get slate400 => _colorIt(child: _childToColor, color: G.slate400);
  T get slate500 => _colorIt(child: _childToColor, color: G.slate500);
  T get slate600 => _colorIt(child: _childToColor, color: G.slate600);
  T get slate700 => _colorIt(child: _childToColor, color: G.slate700);
  T get slate800 => _colorIt(child: _childToColor, color: G.slate800);
  T get slate900 => _colorIt(child: _childToColor, color: G.slate900);

  ///Zinc
  T get zinc50 => _colorIt(child: _childToColor, color: G.zinc50);
  T get zinc100 => _colorIt(child: _childToColor, color: G.zinc100);
  T get zinc200 => _colorIt(child: _childToColor, color: G.zinc200);
  T get zinc300 => _colorIt(child: _childToColor, color: G.zinc300);
  T get zinc400 => _colorIt(child: _childToColor, color: G.zinc400);
  T get zinc500 => _colorIt(child: _childToColor, color: G.zinc500);
  T get zinc600 => _colorIt(child: _childToColor, color: G.zinc600);
  T get zinc700 => _colorIt(child: _childToColor, color: G.zinc700);
  T get zinc800 => _colorIt(child: _childToColor, color: G.zinc800);
  T get zinc900 => _colorIt(child: _childToColor, color: G.zinc900);

  ///Neutral
  T get neutral50 => _colorIt(child: _childToColor, color: G.neutral50);
  T get neutral100 => _colorIt(child: _childToColor, color: G.neutral100);
  T get neutral200 => _colorIt(child: _childToColor, color: G.neutral200);
  T get neutral300 => _colorIt(child: _childToColor, color: G.neutral300);
  T get neutral400 => _colorIt(child: _childToColor, color: G.neutral400);
  T get neutral500 => _colorIt(child: _childToColor, color: G.neutral500);
  T get neutral600 => _colorIt(child: _childToColor, color: G.neutral600);
  T get neutral700 => _colorIt(child: _childToColor, color: G.neutral700);
  T get neutral800 => _colorIt(child: _childToColor, color: G.neutral800);
  T get neutral900 => _colorIt(child: _childToColor, color: G.neutral900);

  ///Stone
  T get stone50 => _colorIt(child: _childToColor, color: G.stone50);
  T get stone100 => _colorIt(child: _childToColor, color: G.stone100);
  T get stone200 => _colorIt(child: _childToColor, color: G.stone200);
  T get stone300 => _colorIt(child: _childToColor, color: G.stone300);
  T get stone400 => _colorIt(child: _childToColor, color: G.stone400);
  T get stone500 => _colorIt(child: _childToColor, color: G.stone500);
  T get stone600 => _colorIt(child: _childToColor, color: G.stone600);
  T get stone700 => _colorIt(child: _childToColor, color: G.stone700);
  T get stone800 => _colorIt(child: _childToColor, color: G.stone800);
  T get stone900 => _colorIt(child: _childToColor, color: G.stone900);

  ///Red
  T get red50 => _colorIt(child: _childToColor, color: G.red50);
  T get red100 => _colorIt(child: _childToColor, color: G.red100);
  T get red200 => _colorIt(child: _childToColor, color: G.red200);
  T get red300 => _colorIt(child: _childToColor, color: G.red300);
  T get red400 => _colorIt(child: _childToColor, color: G.red400);
  T get red500 => _colorIt(child: _childToColor, color: G.red500);
  T get red600 => _colorIt(child: _childToColor, color: G.red600);
  T get red700 => _colorIt(child: _childToColor, color: G.red700);
  T get red800 => _colorIt(child: _childToColor, color: G.red800);
  T get red900 => _colorIt(child: _childToColor, color: G.red900);

  ///Orange
  T get orange50 => _colorIt(child: _childToColor, color: G.orange50);
  T get orange100 => _colorIt(child: _childToColor, color: G.orange100);
  T get orange200 => _colorIt(child: _childToColor, color: G.orange200);
  T get orange300 => _colorIt(child: _childToColor, color: G.orange300);
  T get orange400 => _colorIt(child: _childToColor, color: G.orange400);
  T get orange500 => _colorIt(child: _childToColor, color: G.orange500);
  T get orange600 => _colorIt(child: _childToColor, color: G.orange600);
  T get orange700 => _colorIt(child: _childToColor, color: G.orange700);
  T get orange800 => _colorIt(child: _childToColor, color: G.orange800);
  T get orange900 => _colorIt(child: _childToColor, color: G.orange900);

  ///Amber
  T get amber50 => _colorIt(child: _childToColor, color: G.amber50);
  T get amber100 => _colorIt(child: _childToColor, color: G.amber100);
  T get amber200 => _colorIt(child: _childToColor, color: G.amber200);
  T get amber300 => _colorIt(child: _childToColor, color: G.amber300);
  T get amber400 => _colorIt(child: _childToColor, color: G.amber400);
  T get amber500 => _colorIt(child: _childToColor, color: G.amber500);
  T get amber600 => _colorIt(child: _childToColor, color: G.amber600);
  T get amber700 => _colorIt(child: _childToColor, color: G.amber700);
  T get amber800 => _colorIt(child: _childToColor, color: G.amber800);
  T get amber900 => _colorIt(child: _childToColor, color: G.amber900);

  ///Yellow
  T get yellow50 => _colorIt(child: _childToColor, color: G.yellow50);
  T get yellow100 => _colorIt(child: _childToColor, color: G.yellow100);
  T get yellow200 => _colorIt(child: _childToColor, color: G.yellow200);
  T get yellow300 => _colorIt(child: _childToColor, color: G.yellow300);
  T get yellow400 => _colorIt(child: _childToColor, color: G.yellow400);
  T get yellow500 => _colorIt(child: _childToColor, color: G.yellow500);
  T get yellow600 => _colorIt(child: _childToColor, color: G.yellow600);
  T get yellow700 => _colorIt(child: _childToColor, color: G.yellow700);
  T get yellow800 => _colorIt(child: _childToColor, color: G.yellow800);
  T get yellow900 => _colorIt(child: _childToColor, color: G.yellow900);

  ///Lime
  T get lime50 => _colorIt(child: _childToColor, color: G.lime50);
  T get lime100 => _colorIt(child: _childToColor, color: G.lime100);
  T get lime200 => _colorIt(child: _childToColor, color: G.lime200);
  T get lime300 => _colorIt(child: _childToColor, color: G.lime300);
  T get lime400 => _colorIt(child: _childToColor, color: G.lime400);
  T get lime500 => _colorIt(child: _childToColor, color: G.lime500);
  T get lime600 => _colorIt(child: _childToColor, color: G.lime600);
  T get lime700 => _colorIt(child: _childToColor, color: G.lime700);
  T get lime800 => _colorIt(child: _childToColor, color: G.lime800);
  T get lime900 => _colorIt(child: _childToColor, color: G.lime900);

  ///Green
  T get green50 => _colorIt(child: _childToColor, color: G.green50);
  T get green100 => _colorIt(child: _childToColor, color: G.green100);
  T get green200 => _colorIt(child: _childToColor, color: G.green200);
  T get green300 => _colorIt(child: _childToColor, color: G.green300);
  T get green400 => _colorIt(child: _childToColor, color: G.green400);
  T get green500 => _colorIt(child: _childToColor, color: G.green500);
  T get green600 => _colorIt(child: _childToColor, color: G.green600);
  T get green700 => _colorIt(child: _childToColor, color: G.green700);
  T get green800 => _colorIt(child: _childToColor, color: G.green800);
  T get green900 => _colorIt(child: _childToColor, color: G.green900);

  ///Emerald
  T get emerald50 => _colorIt(child: _childToColor, color: G.emerald50);
  T get emerald100 => _colorIt(child: _childToColor, color: G.emerald100);
  T get emerald200 => _colorIt(child: _childToColor, color: G.emerald200);
  T get emerald300 => _colorIt(child: _childToColor, color: G.emerald300);
  T get emerald400 => _colorIt(child: _childToColor, color: G.emerald400);
  T get emerald500 => _colorIt(child: _childToColor, color: G.emerald500);
  T get emerald600 => _colorIt(child: _childToColor, color: G.emerald600);
  T get emerald700 => _colorIt(child: _childToColor, color: G.emerald700);
  T get emerald800 => _colorIt(child: _childToColor, color: G.emerald800);
  T get emerald900 => _colorIt(child: _childToColor, color: G.emerald900);

  ///teal
  T get teal50 => _colorIt(child: _childToColor, color: G.teal50);
  T get teal100 => _colorIt(child: _childToColor, color: G.teal100);
  T get teal200 => _colorIt(child: _childToColor, color: G.teal200);
  T get teal300 => _colorIt(child: _childToColor, color: G.teal300);
  T get teal400 => _colorIt(child: _childToColor, color: G.teal400);
  T get teal500 => _colorIt(child: _childToColor, color: G.teal500);
  T get teal600 => _colorIt(child: _childToColor, color: G.teal600);
  T get teal700 => _colorIt(child: _childToColor, color: G.teal700);
  T get teal800 => _colorIt(child: _childToColor, color: G.teal800);
  T get teal900 => _colorIt(child: _childToColor, color: G.teal900);

  ///Cyan
  T get cyan50 => _colorIt(child: _childToColor, color: G.cyan50);
  T get cyan100 => _colorIt(child: _childToColor, color: G.cyan100);
  T get cyan200 => _colorIt(child: _childToColor, color: G.cyan200);
  T get cyan300 => _colorIt(child: _childToColor, color: G.cyan300);
  T get cyan400 => _colorIt(child: _childToColor, color: G.cyan400);
  T get cyan500 => _colorIt(child: _childToColor, color: G.cyan500);
  T get cyan600 => _colorIt(child: _childToColor, color: G.cyan600);
  T get cyan700 => _colorIt(child: _childToColor, color: G.cyan700);
  T get cyan800 => _colorIt(child: _childToColor, color: G.cyan800);
  T get cyan900 => _colorIt(child: _childToColor, color: G.cyan900);

  ///Sky
  T get sky50 => _colorIt(child: _childToColor, color: G.sky50);
  T get sky100 => _colorIt(child: _childToColor, color: G.sky100);
  T get sky200 => _colorIt(child: _childToColor, color: G.sky200);
  T get sky300 => _colorIt(child: _childToColor, color: G.sky300);
  T get sky400 => _colorIt(child: _childToColor, color: G.sky400);
  T get sky500 => _colorIt(child: _childToColor, color: G.sky500);
  T get sky600 => _colorIt(child: _childToColor, color: G.sky600);
  T get sky700 => _colorIt(child: _childToColor, color: G.sky700);
  T get sky800 => _colorIt(child: _childToColor, color: G.sky800);
  T get sky900 => _colorIt(child: _childToColor, color: G.sky900);

  ///Blue
  T get blue50 => _colorIt(child: _childToColor, color: G.blue50);
  T get blue100 => _colorIt(child: _childToColor, color: G.blue100);
  T get blue200 => _colorIt(child: _childToColor, color: G.blue200);
  T get blue300 => _colorIt(child: _childToColor, color: G.blue300);
  T get blue400 => _colorIt(child: _childToColor, color: G.blue400);
  T get blue500 => _colorIt(child: _childToColor, color: G.blue500);
  T get blue600 => _colorIt(child: _childToColor, color: G.blue600);
  T get blue700 => _colorIt(child: _childToColor, color: G.blue700);
  T get blue800 => _colorIt(child: _childToColor, color: G.blue800);
  T get blue900 => _colorIt(child: _childToColor, color: G.blue900);

  ///Indigo
  T get indigo50 => _colorIt(child: _childToColor, color: G.indigo50);
  T get indigo100 => _colorIt(child: _childToColor, color: G.indigo100);
  T get indigo200 => _colorIt(child: _childToColor, color: G.indigo200);
  T get indigo300 => _colorIt(child: _childToColor, color: G.indigo300);
  T get indigo400 => _colorIt(child: _childToColor, color: G.indigo400);
  T get indigo500 => _colorIt(child: _childToColor, color: G.indigo500);
  T get indigo600 => _colorIt(child: _childToColor, color: G.indigo600);
  T get indigo700 => _colorIt(child: _childToColor, color: G.indigo700);
  T get indigo800 => _colorIt(child: _childToColor, color: G.indigo800);
  T get indigo900 => _colorIt(child: _childToColor, color: G.indigo900);

  ///Violet
  T get violet50 => _colorIt(child: _childToColor, color: G.violet50);
  T get violet100 => _colorIt(child: _childToColor, color: G.violet100);
  T get violet200 => _colorIt(child: _childToColor, color: G.violet200);
  T get violet300 => _colorIt(child: _childToColor, color: G.violet300);
  T get violet400 => _colorIt(child: _childToColor, color: G.violet400);
  T get violet500 => _colorIt(child: _childToColor, color: G.violet500);
  T get violet600 => _colorIt(child: _childToColor, color: G.violet600);
  T get violet700 => _colorIt(child: _childToColor, color: G.violet700);
  T get violet800 => _colorIt(child: _childToColor, color: G.violet800);
  T get violet900 => _colorIt(child: _childToColor, color: G.violet900);

  ///Purple
  T get purple50 => _colorIt(child: _childToColor, color: G.purple50);
  T get purple100 => _colorIt(child: _childToColor, color: G.purple100);
  T get purple200 => _colorIt(child: _childToColor, color: G.purple200);
  T get purple300 => _colorIt(child: _childToColor, color: G.purple300);
  T get purple400 => _colorIt(child: _childToColor, color: G.purple400);
  T get purple500 => _colorIt(child: _childToColor, color: G.purple500);
  T get purple600 => _colorIt(child: _childToColor, color: G.purple600);
  T get purple700 => _colorIt(child: _childToColor, color: G.purple700);
  T get purple800 => _colorIt(child: _childToColor, color: G.purple800);
  T get purple900 => _colorIt(child: _childToColor, color: G.purple900);

  ///Fuchsia
  T get fuchsia50 => _colorIt(child: _childToColor, color: G.fuchsia50);
  T get fuchsia100 => _colorIt(child: _childToColor, color: G.fuchsia100);
  T get fuchsia200 => _colorIt(child: _childToColor, color: G.fuchsia200);
  T get fuchsia300 => _colorIt(child: _childToColor, color: G.fuchsia300);
  T get fuchsia400 => _colorIt(child: _childToColor, color: G.fuchsia400);
  T get fuchsia500 => _colorIt(child: _childToColor, color: G.fuchsia500);
  T get fuchsia600 => _colorIt(child: _childToColor, color: G.fuchsia600);
  T get fuchsia700 => _colorIt(child: _childToColor, color: G.fuchsia700);
  T get fuchsia800 => _colorIt(child: _childToColor, color: G.fuchsia800);
  T get fuchsia900 => _colorIt(child: _childToColor, color: G.fuchsia900);

  ///Pink
  T get pink50 => _colorIt(child: _childToColor, color: G.pink50);
  T get pink100 => _colorIt(child: _childToColor, color: G.pink100);
  T get pink200 => _colorIt(child: _childToColor, color: G.pink200);
  T get pink300 => _colorIt(child: _childToColor, color: G.pink300);
  T get pink400 => _colorIt(child: _childToColor, color: G.pink400);
  T get pink500 => _colorIt(child: _childToColor, color: G.pink500);
  T get pink600 => _colorIt(child: _childToColor, color: G.pink600);
  T get pink700 => _colorIt(child: _childToColor, color: G.pink700);
  T get pink800 => _colorIt(child: _childToColor, color: G.pink800);
  T get pink900 => _colorIt(child: _childToColor, color: G.pink900);

  ///Rose
  T get rose50 => _colorIt(child: _childToColor, color: G.rose50);
  T get rose100 => _colorIt(child: _childToColor, color: G.rose100);
  T get rose200 => _colorIt(child: _childToColor, color: G.rose200);
  T get rose300 => _colorIt(child: _childToColor, color: G.rose300);
  T get rose400 => _colorIt(child: _childToColor, color: G.rose400);
  T get rose500 => _colorIt(child: _childToColor, color: G.rose500);
  T get rose600 => _colorIt(child: _childToColor, color: G.rose600);
  T get rose700 => _colorIt(child: _childToColor, color: G.rose700);
  T get rose800 => _colorIt(child: _childToColor, color: G.rose800);
  T get rose900 => _colorIt(child: _childToColor, color: G.rose900);

  ///Transparent
  T get transparent {
    velocityColor = Colors.transparent;
    return _childToColor;
  }

  T _colorIt({required Color color, required T child}) {
    velocityColor = color;
    return child;
  }
}
