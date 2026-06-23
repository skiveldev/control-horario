import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'pdf_downloader.dart';

/// Descargador PDF para plataformas mobile/desktop (IO).
///
/// Escribe el archivo en el directorio de documentos de la aplicación.
class PlatformPdfDownloader implements PdfDownloader {
  @override
  Future<void> download({
    required Uint8List bytes,
    required String filename,
    BuildContext? context,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes);
  }
}
