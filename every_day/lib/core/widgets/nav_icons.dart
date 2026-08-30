import 'package:flutter/material.dart';

class FeedNavIcon extends StatelessWidget {
  const FeedNavIcon({super.key, required this.color, this.size = 24});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _RingDotPainter(color: color),
    );
  }
}

class ShelfNavIcon extends StatelessWidget {
  const ShelfNavIcon({super.key, required this.color, this.size = 24});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _StackedPagesPainter(color: color),
    );
  }
}

class GroupsNavIcon extends StatelessWidget {
  const GroupsNavIcon({super.key, required this.color, this.size = 24});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _SplitCirclePainter(color: color),
    );
  }
}

class ProfileNavIcon extends StatelessWidget {
  const ProfileNavIcon({super.key, required this.color, this.size = 24});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _HalfFillCirclePainter(color: color),
    );
  }
}

class _RingDotPainter extends CustomPainter {
  _RingDotPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.12;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, size.width * 0.38, stroke);
    canvas.drawCircle(center, size.width * 0.14, fill);
  }

  @override
  bool shouldRepaint(covariant _RingDotPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _StackedPagesPainter extends CustomPainter {
  _StackedPagesPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.1
      ..strokeCap = StrokeCap.round;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.18,
        size.height * 0.16,
        size.width * 0.64,
        size.height * 0.68,
      ),
      Radius.circular(size.width * 0.12),
    );
    canvas.drawRRect(rect, paint);

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;
    for (final t in [0.40, 0.54, 0.68]) {
      canvas.drawLine(
        Offset(size.width * 0.32, size.height * t),
        Offset(size.width * 0.68, size.height * t),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StackedPagesPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _SplitCirclePainter extends CustomPainter {
  _SplitCirclePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.12;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.38;
    canvas.drawCircle(center, radius, stroke);
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _SplitCirclePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _HalfFillCirclePainter extends CustomPainter {
  _HalfFillCirclePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.12;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.38;
    canvas.drawCircle(center, radius, stroke);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708,
      3.1416,
      true,
      fill,
    );
  }

  @override
  bool shouldRepaint(covariant _HalfFillCirclePainter oldDelegate) =>
      oldDelegate.color != color;
}
