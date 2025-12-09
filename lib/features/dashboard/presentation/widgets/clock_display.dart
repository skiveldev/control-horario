import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors_helper.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';

/// Reloj digital grande con animación
/// 
/// Muestra la hora actual actualizándose cada segundo.
/// Formato: HH:MM:SS
/// 
/// Ejemplo de uso:
/// ```dart
/// ClockDisplay()
/// ```
class ClockDisplay extends StatefulWidget {
  const ClockDisplay({super.key});

  @override
  State<ClockDisplay> createState() => _ClockDisplayState();
}

class _ClockDisplayState extends State<ClockDisplay> {
  late Timer _timer;
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) => _updateTime(),
    );
  }

  void _updateTime() {
    if (mounted) {
      setState(() {
        _currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsHelper.of(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Ícono de reloj
        Container(
          padding: AppSpacing.allMd,
          decoration: BoxDecoration(
            color: colors.secondary, // Cyan para el reloj
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.access_time,
            size: 32,
            color: colors.textOnPrimary,
          ),
        ),

        AppSpacing.verticalSpaceLg,

        // Hora digital
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: Text(
            _currentTime,
            key: ValueKey<String>(_currentTime),
            style: AppTextStyles.displayLarge.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
        ),

        AppSpacing.verticalSpaceXs,

        // Label
        Text(
          'Hora actual',
          style: AppTextStyles.bodySmall.copyWith(
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

