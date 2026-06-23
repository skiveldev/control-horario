import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Servicio multiplataforma para descargar/guardar archivos PDF.
///
/// Usa implementación nativa (path_provider) en mobile/desktop y
/// descarga via navegador en web.
///
/// Para tests, usar [FakePdfDownloader].
abstract class PdfDownloader {
  /// Descarga/guarda los bytes del PDF con el nombre de archivo indicado.
  ///
  /// [bytes] — contenido del PDF.
  /// [filename] — nombre seguro del archivo (ej: "reporte_maria_garcia_2026_05.pdf").
  /// [context] — BuildContext opcional para mostrar feedback visual (SnackBar).
  ///
  /// Lanza excepción si la escritura falla.
  Future<void> download({
    required Uint8List bytes,
    required String filename,
    BuildContext? context,
  });
}

/// Descargador falso para tests — registra llamadas sin efectos de plataforma.
class FakePdfDownloader implements PdfDownloader {
  bool downloadCalled = false;
  Uint8List? lastBytes;
  String? lastFilename;
  BuildContext? lastContext;

  /// Lanzar esta excepción en el próximo [download] si se desea simular error.
  Object? nextError;

  @override
  Future<void> download({
    required Uint8List bytes,
    required String filename,
    BuildContext? context,
  }) async {
    if (nextError != null) {
      final error = nextError;
      nextError = null;
      throw error!;
    }
    downloadCalled = true;
    lastBytes = bytes;
    lastFilename = filename;
    lastContext = context;
  }
}
