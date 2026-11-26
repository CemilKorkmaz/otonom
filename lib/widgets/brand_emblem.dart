import 'package:flutter/material.dart';
import '../models/brand_theme_config.dart';

class BrandEmblem extends StatelessWidget {
  final CarBrandId brandId;
  final String brandName;
  final double size;
  final Color primaryColor;
  final Color secondaryColor;
  final bool asAppIconTile;

  const BrandEmblem({
    super.key,
    required this.brandId,
    this.brandName = 'OTONOM',
    this.size = 42,
    required this.primaryColor,
    required this.secondaryColor,
    this.asAppIconTile = false,
  });

  String _computeMonogram(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 'OT';
    final parts = trimmed.split(RegExp(r'[\s\-]+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return trimmed.substring(0, trimmed.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(asAppIconTile ? size * 0.24 : size * 0.5),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withValues(alpha: 0.32),
            const Color(0xFF0B0E16),
          ],
        ),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.8),
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.35),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: brandId == CarBrandId.other
          ? Center(
              child: Text(
                _computeMonogram(brandName),
                style: TextStyle(
                  fontSize: size * 0.36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                  color: Colors.white,
                ),
              ),
            )
          : CustomPaint(
              painter: _BrandCrestPainter(
                brandId: brandId,
                primaryColor: primaryColor,
                secondaryColor: secondaryColor,
              ),
            ),
    );
  }
}

class _BrandCrestPainter extends CustomPainter {
  final CarBrandId brandId;
  final Color primaryColor;
  final Color secondaryColor;

  const _BrandCrestPainter({
    required this.brandId,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.32;

    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = size.width * 0.065;

    final accentPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    switch (brandId) {
      case CarBrandId.tesla:
        final roofPath = Path()
          ..moveTo(cx - r * 0.85, cy - r * 0.58)
          ..quadraticBezierTo(cx, cy - r * 0.92, cx + r * 0.85, cy - r * 0.58);
        canvas.drawPath(roofPath, strokePaint..color = primaryColor);

        final tPath = Path()
          ..moveTo(cx - r * 0.72, cy - r * 0.30)
          ..quadraticBezierTo(cx, cy - r * 0.48, cx + r * 0.72, cy - r * 0.30)
          ..moveTo(cx, cy - r * 0.38)
          ..lineTo(cx, cy + r * 0.85);
        canvas.drawPath(tPath, strokePaint..color = Colors.white);
        break;

      case CarBrandId.bmw:
        canvas.drawCircle(Offset(cx, cy), r, strokePaint..color = Colors.white);
        final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.78);
        canvas.drawArc(rect, -3.14159 / 2, 3.14159 / 2, true, accentPaint);
        canvas.drawArc(rect, 3.14159 / 2, 3.14159 / 2, true, accentPaint);
        final whiteFill = Paint()..color = Colors.white.withValues(alpha: 0.9);
        canvas.drawArc(rect, 0, 3.14159 / 2, true, whiteFill);
        canvas.drawArc(rect, 3.14159, 3.14159 / 2, true, whiteFill);
        break;

      case CarBrandId.togg:
        final leftGem = Path()
          ..moveTo(cx - r * 0.12, cy)
          ..lineTo(cx - r * 0.85, cy - r * 0.55)
          ..lineTo(cx - r * 0.55, cy)
          ..lineTo(cx - r * 0.85, cy + r * 0.55)
          ..close();
        final rightGem = Path()
          ..moveTo(cx + r * 0.12, cy)
          ..lineTo(cx + r * 0.85, cy - r * 0.55)
          ..lineTo(cx + r * 0.55, cy)
          ..lineTo(cx + r * 0.85, cy + r * 0.55)
          ..close();
        canvas.drawPath(leftGem, Paint()..color = primaryColor);
        canvas.drawPath(rightGem, Paint()..color = Colors.white);
        break;

      case CarBrandId.mercedes:
        canvas.drawCircle(
          Offset(cx, cy),
          r,
          strokePaint
            ..color = Colors.white
            ..strokeWidth = size.width * 0.05,
        );
        final star = Path()
          ..moveTo(cx, cy - r * 0.88)
          ..lineTo(cx, cy)
          ..moveTo(cx, cy)
          ..lineTo(cx - r * 0.76, cy + r * 0.46)
          ..moveTo(cx, cy)
          ..lineTo(cx + r * 0.76, cy + r * 0.46);
        canvas.drawPath(
          star,
          strokePaint
            ..color = primaryColor
            ..strokeWidth = size.width * 0.065,
        );
        break;

      case CarBrandId.porsche:
        final shield = Path()
          ..moveTo(cx - r * 0.7, cy - r * 0.8)
          ..lineTo(cx + r * 0.7, cy - r * 0.8)
          ..lineTo(cx + r * 0.65, cy + r * 0.15)
          ..quadraticBezierTo(cx, cy + r * 0.95, cx, cy + r * 0.95)
          ..quadraticBezierTo(cx, cy + r * 0.95, cx - r * 0.65, cy + r * 0.15)
          ..close();
        canvas.drawPath(shield, Paint()..color = primaryColor.withValues(alpha: 0.35));
        canvas.drawPath(
          shield,
          strokePaint
            ..color = secondaryColor
            ..strokeWidth = size.width * 0.055,
        );
        canvas.drawLine(
          Offset(cx, cy - r * 0.75),
          Offset(cx, cy + r * 0.85),
          strokePaint..color = Colors.white,
        );
        break;

      case CarBrandId.audi:
        final ringRadius = r * 0.36;
        final offsets = [-1.05, -0.35, 0.35, 1.05];
        final ringPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.048;
        for (final factor in offsets) {
          canvas.drawCircle(
            Offset(cx + factor * ringRadius * 1.28, cy),
            ringRadius,
            ringPaint,
          );
        }
        break;

      case CarBrandId.other:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _BrandCrestPainter oldDelegate) {
    return oldDelegate.brandId != brandId ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor;
  }
}
