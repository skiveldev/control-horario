// ignore_for_file: deprecated_member_use

import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/material.dart';

import 'pdf_downloader.dart';

/// Descargador PDF para plataforma web.
///
/// Crea un Blob con los bytes del PDF y dispara la descarga vía navegador.
class PlatformPdfDownloader implements PdfDownloader {
  @override
  Future<void> download({
    required Uint8List bytes,
    required String filename,
    BuildContext? context,
  }) async {
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
