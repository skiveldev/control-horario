import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../utils/password_utils.dart';

/// Campo de contraseña personalizado
///
/// TextField especializado para contraseñas con toggle de visibilidad.
/// Incluye indicador de fortaleza opcional y validaciones comunes.
///
/// Ejemplo de uso:
/// ```dart
/// CustomPasswordField(
///   label: 'Contraseña',
///   controller: passwordController,
///   onChanged: (value) {
///     print('Password: $value');
///   },
/// )
///
/// // Con indicador de fortaleza
/// CustomPasswordField(
///   label: 'Nueva Contraseña',
///   showStrengthIndicator: true,
///   minLength: 8,
///   helperText: 'Mínimo 8 caracteres',
/// )
///
/// // Con validación
/// CustomPasswordField(
///   label: 'Confirmar Contraseña',
///   validator: (value) {
///     if (value != passwordController.text) {
///       return 'Las contraseñas no coinciden';
///     }
///     return null;
///   },
/// )
/// ```
class CustomPasswordField extends StatefulWidget {
  /// Controller del campo
  final TextEditingController? controller;

  /// Etiqueta del campo
  final String? label;

  /// Texto de ayuda
  final String? hintText;

  /// Texto de ayuda adicional
  final String? helperText;

  /// Texto de error
  final String? errorText;

  /// Si el campo es requerido
  final bool required;

  /// Si el campo está habilitado
  final bool enabled;

  /// Longitud mínima (para validación visual)
  final int? minLength;

  /// Longitud máxima
  final int? maxLength;

  /// Mostrar indicador de fortaleza
  final bool showStrengthIndicator;

  /// Callback al cambiar
  final ValueChanged<String>? onChanged;

  /// Callback al enviar
  final ValueChanged<String>? onSubmitted;

  /// Validador personalizado
  final String? Function(String?)? validator;

  /// FocusNode personalizado
  final FocusNode? focusNode;

  /// Auto focus
  final bool autofocus;

  const CustomPasswordField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.required = false,
    this.enabled = true,
    this.minLength,
    this.maxLength,
    this.showStrengthIndicator = false,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  late FocusNode _focusNode;
  bool _obscureText = true;
  bool _isFocused = false;
  String _currentValue = '';

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);

    // Inicializar con el valor del controller si existe
    if (widget.controller != null) {
      _currentValue = widget.controller!.text;
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _handleChanged(String value) {
    setState(() {
      _currentValue = value;
    });
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label personalizado si es requerido
        if (widget.label != null && widget.required)
          Padding(
            padding: AppSpacing.verticalXs,
            child: RichText(
              text: TextSpan(
                text: widget.label!,
                style: AppTextStyles.labelLarge.copyWith(
                  color: widget.errorText != null
                      ? AppColors.error
                      : _isFocused
                          ? AppColors.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                children: const [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: AppColors.error),
                  ),
                ],
              ),
            ),
          ),

        // TextField de contraseña
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          obscureText: _obscureText,
          maxLength: widget.maxLength,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.done,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            labelText:
                widget.label != null && !widget.required ? widget.label : null,
            hintText: widget.hintText ?? '••••••••',
            helperText: widget.helperText,
            errorText: widget.errorText,

            // Ícono de candado
            prefixIcon: Icon(
              Icons.lock_outline,
              size: AppSpacing.iconMd,
              color: widget.errorText != null
                  ? AppColors.error
                  : _isFocused
                      ? AppColors.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
            ),

            // Toggle de visibilidad
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: AppSpacing.iconMd,
              ),
              color: widget.errorText != null
                  ? AppColors.error
                  : _isFocused
                      ? AppColors.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
              onPressed: _toggleVisibility,
              tooltip:
                  _obscureText ? 'Mostrar contraseña' : 'Ocultar contraseña',
            ),

            // Ocultar contador
            counterText: '',

            enabled: widget.enabled,
          ),
          onChanged: _handleChanged,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
        ),

        // Indicador de fortaleza
        if (widget.showStrengthIndicator && _currentValue.isNotEmpty)
          Padding(
            padding: AppSpacing.verticalSm,
            child: _buildStrengthIndicator(),
          ),
      ],
    );
  }

  // ==========================================================================
  // STRENGTH INDICATOR
  // ==========================================================================

  Widget _buildStrengthIndicator() {
    final strength = calculatePasswordStrength(
      _currentValue,
      minLength: widget.minLength ?? 6,
    );
    final strengthData = _getStrengthData(strength, context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Barra de progreso
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
          child: LinearProgressIndicator(
            value: strength / 4,
            minHeight: 4,
            backgroundColor: Theme.of(context).colorScheme.outlineVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              strengthData['color'] as Color,
            ),
          ),
        ),

        AppSpacing.verticalSpaceXs,

        // Texto de fortaleza
        Text(
          strengthData['text'] as String,
          style: AppTextStyles.labelSmall.copyWith(
            color: strengthData['color'] as Color,
          ),
        ),
      ],
    );
  }

  /// Obtiene datos visuales según la fortaleza
  Map<String, dynamic> _getStrengthData(int strength, BuildContext context) {
    switch (strength) {
      case 0:
      case 1:
        return {'text': 'Contraseña débil', 'color': AppColors.error};
      case 2:
        return {'text': 'Contraseña media', 'color': AppColors.warning};
      case 3:
        return {'text': 'Contraseña fuerte', 'color': AppColors.info};
      case 4:
        return {'text': 'Contraseña muy fuerte', 'color': AppColors.success};
      default:
        return {
          'text': '',
          'color': Theme.of(context).colorScheme.onSurfaceVariant,
        };
    }
  }
}
