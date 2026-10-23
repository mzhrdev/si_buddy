import 'dart:io';

import 'package:pdfrx_engine/pdfrx_engine.dart';

import '../domain/document_failures.dart';

/// Text extraction for PDFs, backed by pdfrx_engine (PDFium).
///
/// Everything runs on-device; pages without a text layer simply yield
/// empty strings (OCR for scanned PDFs is a later phase).
class PdfTextExtractor {
  static Future<void>? _initialization;

  /// pdfrx needs one-time initialisation before opening documents.
  Future<void> _ensureInitialized() {
    Pdfrx.cacheDirectoryPath ??= Directory.systemTemp.path;
    return _initialization ??= PdfrxEntryFunctions.instance.init();
  }

  /// Opens [path] and returns its page count.
  ///
  /// Throws [CorruptedDocumentException] when the file is not a
  /// readable PDF.
  Future<int> pageCount(String path) async {
    await _ensureInitialized();
    PdfDocument? document;
    try {
      document = await PdfDocument.openFile(path);
      return document.pages.length;
    } on PdfException catch (e) {
      throw CorruptedDocumentException(
        fileName: path.split(Platform.pathSeparator).last,
        reason: e.message,
      );
    } finally {
      await document?.dispose();
    }
  }

  /// Extracts the text of every page of the PDF at [path], in order.
  ///
  /// [onPageStart] is called with the 0-based page index and the total
  /// page count before each page is read. When [isCancelled] reports
  /// true the extraction stops early and returns what it has so far.
  ///
  /// Throws [CorruptedDocumentException] when the file cannot be read.
  Future<List<String>> extractPageTexts(
    String path, {
    required void Function(int pageIndex, int totalPages) onPageStart,
    required bool Function() isCancelled,
  }) async {
    await _ensureInitialized();
    PdfDocument? document;
    try {
      document = await PdfDocument.openFile(path);
      final total = document.pages.length;
      final texts = <String>[];
      for (var i = 0; i < total; i++) {
        if (isCancelled()) return texts;
        onPageStart(i, total);
        final rawText = await document.pages[i].loadText();
        texts.add(rawText?.fullText.trim() ?? '');
      }
      return texts;
    } on PdfException catch (e) {
      throw CorruptedDocumentException(
        fileName: path.split(Platform.pathSeparator).last,
        reason: e.message,
      );
    } finally {
      await document?.dispose();
    }
  }
}
