import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:vikings_bingo/src/style/spacing.dart';

import '../../style/palette.dart';

class Blur {
  final double sigmaX;
  final double sigmeY;
  const Blur(this.sigmaX, this.sigmeY);
}

class GradientDropShadow extends StatelessWidget {
  final double opacity;
  final double scale;
  final Widget child;
  final Offset offset;
  final Blur blur;
  final Color backgroundColor;
  final Gradient gradient;

  GradientDropShadow({
    this.opacity = 0.5,
    required this.child,
    this.scale = 1,
    this.offset = const Offset(5, 5),
    this.blur = const Blur(1, 1),
    this.backgroundColor = Colors.white,
    required this.gradient,
  }) : assert(opacity >= 0 && opacity <= 1);

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: offset,
            child: Transform.scale(
              scale: scale,
              child: Container(
                padding: EdgeInsets.all(spacingUnit),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(
                      10.0,
                    ),
                  ),
                  gradient: gradient,
                ),
                child: child,
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(spacingUnit),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            color: backgroundColor,
          ),
          child: child,
        ),
      ],
    );
  }
}
