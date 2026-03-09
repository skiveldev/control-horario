/// Tipos de días especiales en un calendario laboral
enum HolidayType {
  /// Festivo Nacional (aplica a toda España)
  national,

  /// Festivo Autonómico o Local (aplica a una región o municipio)
  regional,

  /// Festivo Local (aplica a un municipio concreto)
  local,

  /// Vacaciones o cierre de empresa (periodo no laborable)
  vacation,
}

extension HolidayTypeExtension on HolidayType {
  String get label {
    switch (this) {
      case HolidayType.national:
        return 'Festivo Nacional';
      case HolidayType.regional:
        return 'Festivo Autonómico';
      case HolidayType.local:
        return 'Festivo Local';
      case HolidayType.vacation:
        return 'Vacaciones / Cierre';
    }
  }

  String get shortLabel {
    switch (this) {
      case HolidayType.national:
        return 'Nacional';
      case HolidayType.regional:
        return 'Autonómico';
      case HolidayType.local:
        return 'Local';
      case HolidayType.vacation:
        return 'Vacaciones';
    }
  }
}
