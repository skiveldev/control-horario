import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// Utilidades de animación reutilizables
///
/// Contiene curvas, duraciones y builders de animación comunes.
class AnimationUtils {
  AnimationUtils._();

  // ==========================================================================
  // DURACIONES (Ya definidas en AppConstants, aquí están como referencia)
  // ==========================================================================

  static const Duration fast = AppConstants.durationFast;
  static const Duration normal = AppConstants.durationNormal;
  static const Duration medium = AppConstants.durationMedium;
  static const Duration slow = AppConstants.durationSlow;

  // ==========================================================================
  // CURVAS DE ANIMACIÓN
  // ==========================================================================

  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve sharpCurve = Curves.easeInOutCubic;
  static const Curve smoothCurve = Curves.easeInOutQuart;
  static const Curve bouncyCurve = Curves.elasticOut;
  static const Curve springCurve = Curves.easeOutBack;

  // ==========================================================================
  // SLIDE TRANSITIONS
  // ==========================================================================

  /// Slide desde abajo
  static Widget slideFromBottom(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: defaultCurve)),
      child: child,
    );
  }

  /// Slide desde la derecha
  static Widget slideFromRight(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: defaultCurve)),
      child: child,
    );
  }

  /// Slide desde la izquierda
  static Widget slideFromLeft(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: defaultCurve)),
      child: child,
    );
  }

  // ==========================================================================
  // FADE TRANSITIONS
  // ==========================================================================

  /// Fade simple
  static Widget fade(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurveTween(curve: defaultCurve).animate(animation),
      child: child,
    );
  }

  /// Fade + Scale
  static Widget fadeScale(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurveTween(curve: defaultCurve).animate(animation),
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 0.9,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: smoothCurve)),
        child: child,
      ),
    );
  }

  // ==========================================================================
  // SCALE TRANSITIONS
  // ==========================================================================

  /// Scale simple
  static Widget scale(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return ScaleTransition(
      scale: CurveTween(curve: springCurve).animate(animation),
      child: child,
    );
  }

  // ==========================================================================
  // COMBINED TRANSITIONS
  // ==========================================================================

  /// Slide + Fade (más suave)
  static Widget slideFade(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: defaultCurve)),
      child: FadeTransition(opacity: animation, child: child),
    );
  }
}

/// Widget animado que aparece con fade cuando se monta
class FadeInWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  const FadeInWidget({
    super.key,
    required this.child,
    this.duration = AppConstants.durationMedium,
    this.delay = Duration.zero,
  });

  @override
  State<FadeInWidget> createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<FadeInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _animation, child: widget.child);
  }
}

/// Widget que hace slide desde abajo cuando se monta
class SlideUpWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  const SlideUpWidget({
    super.key,
    required this.child,
    this.duration = AppConstants.durationMedium,
    this.delay = Duration.zero,
  });

  @override
  State<SlideUpWidget> createState() => _SlideUpWidgetState();
}

class _SlideUpWidgetState extends State<SlideUpWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _animation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: _animation, child: widget.child);
  }
}
