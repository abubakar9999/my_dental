import 'package:flutter/material.dart';

class ToothWidget extends StatelessWidget {
  final String toothNumber;
  final String displayName;
  final String condition;
  final List<String> affectedSurfaces;
  final VoidCallback onTap;
  final double size;

  const ToothWidget({
    super.key,
    required this.toothNumber,
    required this.displayName,
    required this.condition,
    this.affectedSurfaces = const [],
    required this.onTap,
    this.size = 46.0,
  });

  Color _getConditionColor(String cond) {
    switch (cond.toLowerCase()) {
      case 'caries':
        return const Color(0xFFE53935); // Red
      case 'filled':
        return const Color(0xFF1E88E5); // Blue
      case 'crown':
        return const Color(0xFFFBC02D); // Yellow / Gold
      case 'extracted':
        return const Color(0xFF616161); // Grey / Black
      case 'rct':
        return const Color(0xFF8E24AA); // Purple
      case 'healthy':
      default:
        return const Color(0xFF43A047); // Green
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = _getConditionColor(condition);
    final isExtracted = condition.toLowerCase() == 'extracted';
    final isHealthy = condition.toLowerCase() == 'healthy';

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tooth Number label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: baseColor.withAlpha(30),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              displayName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isHealthy ? Colors.teal.shade900 : baseColor,
              ),
            ),
          ),
          const SizedBox(height: 3),

          // 2D Tooth Odontogram (5 surfaces)
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _ToothPainter(
                baseColor: baseColor,
                condition: condition,
                isExtracted: isExtracted,
                affectedSurfaces: affectedSurfaces,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToothPainter extends CustomPainter {
  final Color baseColor;
  final String condition;
  final bool isExtracted;
  final List<String> affectedSurfaces;

  _ToothPainter({
    required this.baseColor,
    required this.condition,
    required this.isExtracted,
    required this.affectedSurfaces,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final borderPaint = Paint()
      ..color = Colors.blueGrey.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    if (isExtracted) {
      // Missing / Extracted: Draw cross
      final crossPaint = Paint()
        ..color = Colors.black87
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      canvas.drawCircle(
        Offset(w / 2, h / 2),
        w * 0.45,
        Paint()
          ..color = Colors.grey.shade300
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(Offset(w / 2, h / 2), w * 0.45, borderPaint);

      canvas.drawLine(
        Offset(w * 0.2, h * 0.2),
        Offset(w * 0.8, h * 0.8),
        crossPaint,
      );
      canvas.drawLine(
        Offset(w * 0.8, h * 0.2),
        Offset(w * 0.2, h * 0.8),
        crossPaint,
      );
      return;
    }

    final hasSpecificSurfaces = affectedSurfaces.isNotEmpty;
    final isHealthy = condition.toLowerCase() == 'healthy';

    Color getSurfaceColor(String surfaceName) {
      if (hasSpecificSurfaces) {
        if (affectedSurfaces.contains(surfaceName)) {
          return baseColor;
        }
        return const Color(0xFFF1F8E9); // Light Healthy Tint
      }
      return isHealthy ? const Color(0xFFF1F8E9) : baseColor;
    }

    // Geometry of standard 5 surfaces
    final inset = w * 0.28;

    // 1. Buccal / Facial (Top trapezoid)
    final buccalPath = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w - inset, inset)
      ..lineTo(inset, inset)
      ..close();
    canvas.drawPath(
      buccalPath,
      Paint()
        ..color = getSurfaceColor('buccal')
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(buccalPath, borderPaint);

    // 2. Lingual / Palatal (Bottom trapezoid)
    final lingualPath = Path()
      ..moveTo(0, h)
      ..lineTo(w, h)
      ..lineTo(w - inset, h - inset)
      ..lineTo(inset, h - inset)
      ..close();
    canvas.drawPath(
      lingualPath,
      Paint()
        ..color = getSurfaceColor('lingual')
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(lingualPath, borderPaint);

    // 3. Mesial (Left trapezoid)
    final mesialPath = Path()
      ..moveTo(0, 0)
      ..lineTo(inset, inset)
      ..lineTo(inset, h - inset)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      mesialPath,
      Paint()
        ..color = getSurfaceColor('mesial')
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(mesialPath, borderPaint);

    // 4. Distal (Right trapezoid)
    final distalPath = Path()
      ..moveTo(w, 0)
      ..lineTo(w - inset, inset)
      ..lineTo(w - inset, h - inset)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(
      distalPath,
      Paint()
        ..color = getSurfaceColor('distal')
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(distalPath, borderPaint);

    // 5. Occlusal / Incisal (Center rectangle)
    final occlusalRect = Rect.fromLTWH(inset, inset, w - 2 * inset, h - 2 * inset);
    canvas.drawRect(
      occlusalRect,
      Paint()
        ..color = getSurfaceColor('occlusal')
        ..style = PaintingStyle.fill,
    );
    canvas.drawRect(occlusalRect, borderPaint);

    // If RCT: draw a purple root canal marker inside center
    if (condition.toLowerCase() == 'rct') {
      final rctPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(Offset(w / 2, h / 2), w * 0.12, rctPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ToothPainter oldDelegate) {
    return oldDelegate.baseColor != baseColor ||
        oldDelegate.condition != condition ||
        oldDelegate.isExtracted != isExtracted ||
        oldDelegate.affectedSurfaces != affectedSurfaces;
  }
}
