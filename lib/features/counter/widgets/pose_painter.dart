import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../engine/rep_counter_engine.dart';

class PosePainter extends CustomPainter {
  final Map<int, PoseKeypoint> landmarks;
  final Size imageSize;
  final bool isFrontCamera;
  final bool isFormValid;
  final double currentElbowAngle;

  PosePainter({
    required this.landmarks,
    required this.imageSize,
    this.isFrontCamera = true,
    this.isFormValid = true,
    required this.currentElbowAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (landmarks.isEmpty || imageSize.width == 0 || imageSize.height == 0) return;

    final double scaleX = size.width / imageSize.width;
    final double scaleY = size.height / imageSize.height;

    final Paint linePaint = Paint()
      ..color = isFormValid ? AppColors.primary : AppColors.danger
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    final Paint jointPaint = Paint()
      ..color = isFormValid ? AppColors.primary : AppColors.danger
      ..style = PaintingStyle.fill;

    final Paint glowPaint = Paint()
      ..color = (isFormValid ? AppColors.primary : AppColors.danger).withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    PointMapper mapper = PointMapper(
      scaleX: scaleX,
      scaleY: scaleY,
      sizeWidth: size.width,
      isFrontCamera: isFrontCamera,
    );

    // Standard connections (Left Arm, Right Arm, Torso)
    const connections = [
      [11, 13], // Left Shoulder -> Left Elbow
      [13, 15], // Left Elbow -> Left Wrist
      [12, 14], // Right Shoulder -> Right Elbow
      [14, 16], // Right Elbow -> Right Wrist
      [11, 12], // Left Shoulder -> Right Shoulder
      [11, 23], // Left Shoulder -> Left Hip
      [12, 24], // Right Shoulder -> Right Hip
      [23, 24], // Left Hip -> Right Hip
      [23, 27], // Left Hip -> Left Ankle
      [24, 28], // Right Hip -> Right Ankle
    ];

    // Draw skeletal bones
    for (final conn in connections) {
      final p1 = landmarks[conn[0]];
      final p2 = landmarks[conn[1]];
      if (p1 != null && p2 != null) {
        final offset1 = mapper.map(p1.x, p1.y);
        final offset2 = mapper.map(p2.x, p2.y);
        canvas.drawLine(offset1, offset2, linePaint);
      }
    }

    // Draw joint dots
    landmarks.forEach((index, kp) {
      final offset = mapper.map(kp.x, kp.y);
      canvas.drawCircle(offset, 6.0, glowPaint);
      canvas.drawCircle(offset, 4.0, jointPaint);
    });

    // Draw angle badge near the active elbow (if available)
    final elbowKp = landmarks[13] ?? landmarks[14];
    if (elbowKp != null) {
      final offset = mapper.map(elbowKp.x, elbowKp.y);
      _drawAngleBadge(canvas, offset, currentElbowAngle);
    }
  }

  void _drawAngleBadge(Canvas canvas, Offset position, double angle) {
    final textSpan = TextSpan(
      text: '${angle.round()}°',
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        backgroundColor: AppColors.bgCardSolid,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final badgeOffset = position + const Offset(12, -12);
    final bgRect = Rect.fromLTWH(
      badgeOffset.dx - 4,
      badgeOffset.dy - 2,
      textPainter.width + 8,
      textPainter.height + 4,
    );

    final bgPaint = Paint()
      ..color = AppColors.bgMain.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(RRect.fromRectAndRadius(bgRect, const Radius.circular(4)), bgPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(bgRect, const Radius.circular(4)), borderPaint);
    textPainter.paint(canvas, badgeOffset);
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.currentElbowAngle != currentElbowAngle ||
        oldDelegate.isFormValid != isFormValid ||
        oldDelegate.landmarks != landmarks;
  }
}

class PointMapper {
  final double scaleX;
  final double scaleY;
  final double sizeWidth;
  final bool isFrontCamera;

  PointMapper({
    required this.scaleX,
    required this.scaleY,
    required this.sizeWidth,
    required this.isFrontCamera,
  });

  Offset map(double x, double y) {
    double mappedX = x * scaleX;
    if (isFrontCamera) {
      mappedX = sizeWidth - mappedX;
    }
    return Offset(mappedX, y * scaleY);
  }
}
