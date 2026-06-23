import 'pdf_downloader.dart';

import 'pdf_downloader_io.dart'
    if (dart.library.html) 'pdf_downloader_web.dart';

/// Crea la implementación de [PdfDownloader] adecuada para la plataforma actual.
///
/// En mobile/desktop → implementación IO.
/// En web → implementación con descarga via navegador.
PdfDownloader createPlatformPdfDownloader() {
  return PlatformPdfDownloader();
}
