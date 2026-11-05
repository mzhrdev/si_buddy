import 'dart:io';

import 'package:pdfrx_engine/pdfrx_engine.dart';

import '../domain/document_failures.dart';
import 'mlkit_ocr_engine.dart';
import 'ocr_engine.dart';

/// Text extraction for PDFs, backed by pdfrx_engine (PDFium).
///
/// Everything runs on-device. Pages with a text layer are read from
/// it directly; pages without one (scanned, image-only pages) are
/// rendered to an image and read with on-device OCR ([OcrEngine]).
/// A page whose OCR fails still yields an empty string — extraction
/// succeeds and the document is flagged `hasText: false` downstream.
class PdfTextExtractor {
  PdfTextExtractor({OcrEngine? ocrEngine})
    : _ocrEngine = ocrEngine ?? const MlKitOcrEngine();

  static Future<void>? _initialization;

  /// The OCR engine text-less pages are read with.
  final OcrEngine _ocrEngine;

  /// Render scale for OCR pages, in output pixels per PDF point
  /// (2.0 ≈ 144 DPI): readable enough for ML Kit without the
  /// multi-megabyte images full 300 DPI rendering would produce.
  static const double _ocrRenderScale = 2;

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
  /// page count before each page is read. [onOcrPageStart] is called
  /// the same way when a page has no text layer and OCR begins, so
  /// the caller can report the slower scanned-page work honestly.
  /// When [isCancelled] reports true the extraction stops early and
  /// returns what it has so far.
  ///
  /// Throws [CorruptedDocumentException] when the file cannot be read.
  Future<List<String>> extractPageTexts(
    String path, {
    required void Function(int pageIndex, int totalPages) onPageStart,
    required bool Function() isCancelled,
    void Function(int pageIndex, int totalPages)? onOcrPageStart,
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
        final page = document.pages[i];
        var text = (await page.loadText())?.fullText.trim() ?? '';
        if (text.isEmpty) {
          // Scanned page: no text layer. Render it and read it
          // with OCR instead of leaving it blank.
          if (isCancelled()) return texts;
          onOcrPageStart?.call(i, total);
          text = await _ocrPage(page, isCancelled: isCancelled);
        }
        texts.add(text);
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

  /// Renders [page] and reads it with OCR. Returns the recognized
  /// text, or an empty string when rendering or recognition fails
  /// (or the job was cancelled while the page was being read).
  Future<String> _ocrPage(
    PdfPage page, {
    required bool Function() isCancelled,
  }) async {
    final width = (page.width * _ocrRenderScale).round();
    final height = (page.height * _ocrRenderScale).round();
    if (width <= 0 || height <= 0) return '';
    PdfImage? image;
    try {
      image = await page.render(width: width, height: height);
      if (image == null || isCancelled()) return '';
      final recognized = await _ocrEngine.recognizePage(
        bgraPixels: image.pixels,
        width: image.width,
        height: image.height,
      );
      return recognized.trim();
    } on Object {
      return '';
    } finally {
      image?.dispose();
    }
  }
}
