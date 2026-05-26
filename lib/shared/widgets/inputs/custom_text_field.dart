import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

/// Campo de texto personalizado del Control Horario
///
/// TextField reutilizable con diseño consistente, soporte para
/// validación visual, prefijos, sufijos e íconos.
///
/// Ejemplo de uso:
/// ```dart
/// CustomTextField(
///   label: 'Correo electrónico',
///   hintText: 'tu@empresa.com',
///   prefixIcon: Icons.email,
///   keyboardType: TextInputType.emailAddress,
///   onChanged: (value) {
///     print('Email: $value');
///   },
/// )
///
/// // Con validación
/// CustomTextField(
///   label: 'Nombre',
///   controller: nombreController,
///   errorText: 'El nombre es requerido',
///   maxLength: 50,
/// )
///
/// // Con sufijo personalizado
/// CustomTextField(
///   label: 'Búsqueda',
///   suffixIcon: Icons.search,
///   onSubmitted: (value) {
///     _realizarBusqueda(value);
///   },
/// )
/// ```
class CustomTextField extends StatefulWidget {
  /// Controller del campo de texto
  final TextEditingController? controller;

  /// Etiqueta del campo
  final String? label;

  /// Texto de ayuda (placeholder)
  final String? hintText;

  /// Texto de ayuda adicional debajo del campo
  final String? helperText;

  /// Texto de error (muestra el estado de error)
  final String? errorText;

  /// Valor inicial del campo
  final String? initialValue;

  /// Si el campo es requerido (muestra *)
  final bool required;

  /// Si el campo está habilitado
  final bool enabled;

  /// Si el campo es de solo lectura
  final bool readOnly;

  /// Número máximo de líneas (1 para input normal, >1 para textarea)
  final int maxLines;

  /// Número mínimo de líneas (para textarea)
  final int? minLines;

  /// Longitud máxima de caracteres
  final int? maxLength;

  /// Tipo de teclado
  final TextInputType keyboardType;

  /// Acción del teclado (done, next, search, etc.)
  final TextInputAction? textInputAction;

  /// Capitalización automática
  final TextCapitalization textCapitalization;

  /// Input formatters (máscaras, restricciones)
  final List<TextInputFormatter>? inputFormatters;

  /// Ícono prefijo (izquierda)
  final IconData? prefixIcon;

  /// Widget prefijo personalizado
  final Widget? prefix;

  /// Texto prefijo
  final String? prefixText;

  /// Ícono sufijo (derecha)
  final IconData? suffixIcon;

  /// Widget sufijo personalizado
  final Widget? suffix;

  /// Texto sufijo
  final String? suffixText;

  /// Callback al cambiar el texto
  final ValueChanged<String>? onChanged;

  /// Callback al enviar (presionar enter)
  final ValueChanged<String>? onSubmitted;

  /// Callback cuando el campo gana focus
  final VoidCallback? onTap;

  /// Validador personalizado
  final String? Function(String?)? validator;

  /// FocusNode personalizado
  final FocusNode? focusNode;

  /// Auto focus al cargar
  final bool autofocus;

  /// Ocultar contador de caracteres (cuando hay maxLength)
  final bool hideCounter;

  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.initialValue,
    this.required = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.prefixIcon,
    this.prefix,
    this.prefixText,
    this.suffixIcon,
    this.suffix,
    this.suffixText,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.focusNode,
    this.autofocus = false,
    this.hideCounter = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label personalizado (opcional, además del que tiene TextField)
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

        // TextField
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          focusNode: _focusNode,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          autofocus: widget.autofocus,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          inputFormatters: widget.inputFormatters,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            labelText:
                widget.label != null && !widget.required ? widget.label : null,
            hintText: widget.hintText,
            helperText: widget.helperText,
            errorText: widget.errorText,

            // Prefijos
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    size: AppSpacing.iconMd,
                    color: widget.errorText != null
                        ? AppColors.error
                        : _isFocused
                            ? AppColors.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                  )
                : null,
            prefix: widget.prefix,
            prefixText: widget.prefixText,

            // Sufijos
            suffixIcon: widget.suffixIcon != null
                ? Icon(
                    widget.suffixIcon,
                    size: AppSpacing.iconMd,
                    color: widget.errorText != null
                        ? AppColors.error
                        : _isFocused
                            ? AppColors.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                  )
                : null,
            suffix: widget.suffix,
            suffixText: widget.suffixText,

            // Ocultar contador si es necesario
            counterText: widget.hideCounter ? '' : null,

            // Estados
            enabled: widget.enabled,
          ),
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          validator: widget.validator,
        ),
      ],
    );
  }
}
