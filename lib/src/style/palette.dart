import 'dart:math';

import 'package:flutter/material.dart';

final _random = Random();

class Palette {
  // Actual colors
  Color get _trueWhite => const Color(0xffffffff);
  Color get _inkFullOpacity => const Color(0xff352b42);
  Color get _ink => const Color(0xee352b42);
  Color get _englishPurple => const Color(0xff632e83);
  Color get _greenSheen => const Color(0xff73C0B8);
  Color get _flame => const Color(0xffDD6031);
  Color get _black => const Color(0xff232121);

  Color get _languidLavender => const Color(0xFFE4D5EC);
  Color get _thistle => const Color(0xFFD1B9DF);
  Color get _lilac => const Color(0xFFC8ABD8);
  Color get _wisteria => const Color(0xFFC09DD2);
  Color get _africanViolet => const Color(0xFFB78FCC);
  Color get _purpleMountainMajesty => const Color(0xFFA373BF);

  // Colors by use-case
  // Background by page
  Color get backgroundMain => _languidLavender;
  Color get backgroundSecondary => _englishPurple;
  Color get white => _trueWhite;
  Color get black => _black;

  // inks
  Color get mainInk => _ink;
  Color get mainInkFullCapacity => _inkFullOpacity;
  Color get lightInk => _trueWhite;

  List<Color> get cascadePurple => [
        _thistle,
        _lilac,
        _wisteria,
        _africanViolet,
        _purpleMountainMajesty,
      ];

  List<Color> get cascadeBlackAndWhite => [
        _black,
        const Color(0xFF3A3737),
        const Color(0xff5b5555),
        const Color(0xff8d8585),
        const Color(0xffbeb4b4),
        _trueWhite,
      ];

  // Repeats of colors to control how often a color is selected
  // purely for aesthetics
  Color get randomColor {
    final options = [
      _flame,
      _flame,
      _englishPurple,
      _greenSheen,
      _greenSheen,
      _greenSheen
    ];
    return options[_random.nextInt(options.length)];
  }
}
