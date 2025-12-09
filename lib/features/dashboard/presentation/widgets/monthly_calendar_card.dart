import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors_helper.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/mock_data.dart';
import '../../../../shared/widgets/cards/custom_card.dart';
import '../../../../shared/widgets/buttons/icon_button_custom.dart';
import 'calendar_grid.dart';
import 'calendar_legend.dart';

/// Card de calendario mensual
/// 
/// Muestra el calendario del mes actual con indicadores
/// de días especiales (festivos, vacaciones, eventos, etc.).
/// 
/// MOCK DATA: Usa MockData.calendarDays
class MonthlyCalendarCard extends StatefulWidget {
  const MonthlyCalendarCard({super.key});

  @override
  State<MonthlyCalendarCard> createState() => _MonthlyCalendarCardState();
}

class _MonthlyCalendarCardState extends State<MonthlyCalendarCard> {
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
  }

  void _goToPreviousMonth() {
    setState(() {
      _currentDate = DateTime(
        _currentDate.year,
        _currentDate.month - 1,
      );
    });
  }

  void _goToNextMonth() {
    setState(() {
      _currentDate = DateTime(
        _currentDate.year,
        _currentDate.month + 1,
      );
    });
  }

  void _goToToday() {
    setState(() {
      _currentDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthName = _getMonthName(_currentDate);
    final colors = AppColorsHelper.of(context);
    final isCurrentMonth = _currentDate.year == DateTime.now().year &&
        _currentDate.month == DateTime.now().month;

    return CustomCard(
      elevation: CardElevation.medium,
      padding: AppSpacing.cardLarge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con navegación
          Row(
            children: [
              Icon(
                Icons.calendar_month,
                size: AppSpacing.iconMd,
                color: colors.accent,
              ),
              AppSpacing.horizontalSpaceSm,
              Expanded(
                child: Text(
                  monthName.capitalize(),
                  style: AppTextStyles.h5.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),

              // Botones de navegación
              IconButtonCustom(
                icon: Icons.chevron_left,
                size: IconButtonSize.medium,
                variant: IconButtonVariant.tonal,
                onPressed: _goToPreviousMonth,
                tooltip: 'Mes anterior',
              ),

              AppSpacing.horizontalSpaceXs,

              // Botón "Hoy"
              if (!isCurrentMonth)
                TextButton(
                  onPressed: _goToToday,
                  style: TextButton.styleFrom(
                    padding: AppSpacing.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    minimumSize: Size.zero,
                  ),
                  child: const Text('Hoy'),
                ),

              AppSpacing.horizontalSpaceXs,

              IconButtonCustom(
                icon: Icons.chevron_right,
                size: IconButtonSize.medium,
                variant: IconButtonVariant.tonal,
                onPressed: _goToNextMonth,
                tooltip: 'Mes siguiente',
              ),
            ],
          ),

          AppSpacing.verticalSpaceLg,

          // Grid del calendario
          CalendarGrid(
            year: _currentDate.year,
            month: _currentDate.month,
            currentDay: isCurrentMonth ? DateTime.now().day : -1,
            specialDays: MockData.calendarDays,
            onDayTap: (day) {
              // TODO [FASE-2]: Mostrar detalle del día
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Día $day seleccionado'),
                ),
              );
            },
          ),

          AppSpacing.verticalSpaceLg,

          // Leyenda
          const CalendarLegend(),
        ],
      ),
    );
  }

  /// Obtiene el nombre del mes en español
  String _getMonthName(DateTime date) {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];

    return '${months[date.month - 1]} ${date.year}';
  }
}

/// Extensión para capitalizar strings
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}

