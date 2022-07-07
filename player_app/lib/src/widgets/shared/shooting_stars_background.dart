import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';

const _defaultColors = [
  Color(0xff632e83),
  Color(0xff73C0B8),
  Color(0xffDD6031),
];

class ShootingStarsBackground extends StatefulWidget {
  final bool isStopped;

  final List<Color> colors;

  const ShootingStarsBackground({
    this.colors = _defaultColors,
    this.isStopped = false,
    super.key,
  });

  @override
  State<ShootingStarsBackground> createState() =>
      _ShootingStarsBackgroundState();
}

class _ShootingStarsBackgroundState extends State<ShootingStarsBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant ShootingStarsBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isStopped && !widget.isStopped) {
      _controller.repeat();
    } else if (!oldWidget.isStopped && widget.isStopped) {
      _controller.stop(canceled: false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ShootingStarsBackgroundPainter(
        animation: _controller,
        colors: widget.colors,
      ),
      willChange: true,
      child: const SizedBox.expand(),
    );
  }
}

class ShootingStarsBackgroundPainter extends CustomPainter {
  ShootingStarsBackgroundPainter({
    required Listenable animation,
    required List<Color> colors,
  })  : colors = UnmodifiableListView(colors),
        super(repaint: animation);

  final defaultPaint = Paint();

  final int starCount = 1;

  late final List<_Star> _stars;

  Size? _size;

  DateTime _lastTime = DateTime.now();

  final UnmodifiableListView<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    if (_size == null) {
      _stars = List.generate(
        starCount,
        (i) => _Star(
          frontColor: colors[i % colors.length],
          bounds: size,
        ),
      );
    }
    final didResize = _size != null && _size != size;
    final now = DateTime.now();
    final dt = now.difference(_lastTime);

    for (final s in _stars) {
      if (didResize) {
        s.updateBounds(size);
      }

      if (s.willDieEarly) {
        s.updateDeadStar();
      } else {
        s.update(dt.inMilliseconds / 2000);
      }

      s.draw(canvas);
    }

    _size = size;
    _lastTime = now;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class _Star {
  static final Random _random = Random();
  static final Random _tailRandom = Random();

  static const degToRad = pi / 180;

  static const backSideBlend = Color(0x70EEEEEE);

  Size _bounds;

  late final _Vector position = _Vector(
    0 - _random.nextInt(10).toDouble(), // start far off screen
    _random.nextInt(_bounds.height.toInt() + 100).toDouble() / 100,
  );

  final double angle = _random.nextDouble() * 360 * degToRad;

  final double size = 1;

  final double xSpeed = 400;

  final double ySpeed = 400;

  int tailLength = 25;

  // left over from the confetti animation at [github/filiph/tictactoe]
  // no clue what it says, but I think it's making the shape of the
  // "stars" differnet. they're so small here that it doesnt matter.
  late List<_Vector> corners = List.generate(4, (i) {
    final angle = this.angle + degToRad * (45 + i * 90);
    return _Vector(cos(angle), sin(angle));
  });

  double time = _random.nextDouble();

  Color frontColor;

  late final Color backColor = Color.alphaBlend(backSideBlend, frontColor);

  final paint = Paint()..style = PaintingStyle.fill;

  _Star({
    required this.frontColor,
    required Size bounds,
  }) : _bounds = bounds;

  void draw(Canvas canvas) {
    paint.color = frontColor;

    // The polygon is the star itself (which is actually a small square)
    final path = Path()
      ..addPolygon(
        List.generate(
            4,
            (index) => Offset(
                  position.x + corners[index].x * size,
                  position.y + corners[index].y * size,
                )),
        true,
      );
    if (willDieEarly) {
      drawTwinkle(canvas);
    } else {
      canvas.drawPath(path, paint);
    }
    // this line is the "tail" of the star
    canvas.drawLine(
        Offset(position.x, position.y),
        Offset(position.x - tailLength, position.y + tailLength),
        paint..strokeWidth = .5);
  }

  double qNum = 0;
  void drawTwinkle(Canvas canvas) {
    double y = position.y;
    double x = position.x;

    qNum += .05;

    final paint = Paint()
      ..color = frontColor
      ..style = PaintingStyle.stroke;

    Path path = Path()
      ..moveTo(x, y)
      ..lineTo(x - qNum, y - qNum)
      ..lineTo(x + qNum, y + qNum)
      ..moveTo(x, y)
      ..lineTo(x - qNum, y + qNum)
      ..lineTo(x + qNum, y - qNum);

    canvas.drawPath(path, paint);
  }

  bool willDieEarly = false;

  void update(double dt) {
    willDieEarly =
        (_random.nextInt(10) == 1 && position.x > (_bounds.width * .5));
    if (willDieEarly) return;

    // This  advances the position on the screen.
    position.x += xSpeed * dt;
    position.y += -ySpeed * dt;

    // this gives the stars a tail that appears to be
    // flashing like the fire from the back of a rocket
    tailLength = _tailRandom.nextInt(20) + 10;
    // Move the star back to the beginning, which makes it
    // appear to be a new star
    if ((position.y < -1000 || position.x > _bounds.width + 4000)) {
      resetStarPosition();
    }
  }

  void updateDeadStar() {
    tailLength -= 2;
    if (tailLength <= 0) {
      willDieEarly = false;
      qNum = 0;
      resetStarPosition();
    }
  }

  void resetStarPosition() {
    frontColor = _defaultColors[_random.nextInt(2)];
    position.x = -10 - _random.nextInt(100).toDouble();
    position.y = _random.nextDouble() * _bounds.height;
  }

  void updateBounds(Size newBounds) {
    if (!newBounds.contains(Offset(position.x, position.y))) {
      position.x = _random.nextDouble() * newBounds.width;
      position.y = _random.nextDouble() * newBounds.height;
    }
    _bounds = newBounds;
  }
}

class _Vector {
  double x, y;
  _Vector(this.x, this.y);
}
