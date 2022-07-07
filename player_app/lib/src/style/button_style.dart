import 'package:flutter/material.dart';
import 'package:vikings_bingo/src/style/palette.dart';

final ButtonStyle outlineButtonStyle = OutlinedButton.styleFrom(
  primary: Palette().primary,
  padding: const EdgeInsets.symmetric(horizontal: 16),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(2)),
  ),
).copyWith(
  side: MaterialStateProperty.resolveWith<BorderSide>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.pressed)) {
        return BorderSide(
          color: Palette().secondary,
          width: 1,
        ); // Defer to the widget's default.
      } else {
        return BorderSide(
          color: Palette().secondary,
        );
      }
    },
  ),
);

final ButtonStyle secondaryButtonStyle = TextButton.styleFrom(
  primary: Palette().primary,
  padding: const EdgeInsets.symmetric(horizontal: 16),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(2)),
  ),
);
