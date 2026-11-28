import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// GPU-only (Transform / Opacity) motion primitives respecting reduced-motion.
class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 140);
  static const Duration standard = Duration(milliseconds: 240);
  static const Duration ring = Duration(milliseconds: 600);
  static const Duration countUp = Duration(milliseconds: 450);

  static bool reduceMotion(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);
}

/// Spring-like press scale feedback (0.97) with optional light haptic.
class AppPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool enableHaptics;

  const AppPressable({
    super.key,
    required this.child,
    this.onTap,
    this.enableHaptics = true,
  });

  @override
  State<AppPressable> createState() => _AppPressableState();
}

class _AppPressableState extends State<AppPressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final reduce = AppMotion.reduceMotion(context);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: widget.onTap == null
          ? null
          : (_) => setState(() => _pressed = true),
      onTapUp: widget.onTap == null
          ? null
          : (_) => setState(() => _pressed = false),
      onTapCancel: widget.onTap == null
          ? null
          : () => setState(() => _pressed = false),
      onTap: widget.onTap == null
          ? null
          : () {
              if (widget.enableHaptics) {
                HapticFeedback.lightImpact();
              }
              widget.onTap!();
            },
      child: AnimatedScale(
        scale: (_pressed && !reduce) ? 0.97 : 1.0,
        duration: reduce ? Duration.zero : AppMotion.fast,
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

/// Staggered entrance using Transform.translate + Opacity only.
class AppStaggeredEntrance extends StatefulWidget {
  final int index;
  final Widget child;

  const AppStaggeredEntrance({
    super.key,
    required this.index,
    required this.child,
  });

  @override
  State<AppStaggeredEntrance> createState() => _AppStaggeredEntranceState();
}

class _AppStaggeredEntranceState extends State<AppStaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.standard,
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    final delayMs = (widget.index.clamp(0, 8)) * 35;
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduceMotion(context)) {
      return widget.child;
    }
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}

/// Smooth count-up integer text with reduced-motion fallback.
class AppCountUpText extends StatelessWidget {
  final int target;
  final TextStyle style;
  final String prefix;
  final String suffix;
  final int? maxLines;

  const AppCountUpText({
    super.key,
    required this.target,
    required this.style,
    this.prefix = '',
    this.suffix = '',
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduceMotion(context)) {
      return Text(
        '$prefix$target$suffix',
        style: style,
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
      );
    }

    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: target),
      duration: AppMotion.countUp,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Text(
          '$prefix$value$suffix',
          style: style,
          maxLines: maxLines,
          overflow: maxLines != null ? TextOverflow.ellipsis : null,
        );
      },
    );
  }
}

