import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:si_buddy/app/router.dart';
import 'package:si_buddy/core/database/app_database.dart';
import 'package:si_buddy/features/documents/data/document_repository_impl.dart';
import 'package:si_buddy/features/documents/data/ocr_engine.dart';
import 'package:si_buddy/features/documents/data/pdf_text_extractor.dart';
import 'package:si_buddy/features/documents/domain/document_models.dart';
import 'package:si_buddy/features/documents/presentation/screens/text_extraction_processing_screen.dart';

/// A fake OCR engine: returns canned text (or throws) and records
/// how often it was asked, so tests can prove the extractor only
/// falls back to OCR for pages without a text layer.
class FakeOcrEngine implements OcrEngine {
  FakeOcrEngine({this.result = '', this.throws = false});

  final String result;
  final bool throws;
  int calls = 0;
  int? lastWidth;
  int? lastHeight;

  @override
  Future<String> recognizePage({
    required Uint8List bgraPixels,
    required int width,
    required int height,
  }) async {
    calls++;
    lastWidth = width;
    lastHeight = height;
    if (throws) throw StateError('OCR unavailable');
    return result;
  }
}

// ---------------------------------------------------------------------------
// Minimal PDF builder: assembles valid one- and two-page PDFs with
// computed xref offsets. A page is either a text page (Helvetica Tj)
// or an image-only page (an 8x8 RGB XObject, no text operators).
// ---------------------------------------------------------------------------

List<int> _ascii(String s) => ascii.encode(s);

List<int> _stream(List<int> data, String dict) {
  return [
    ..._ascii('$dict\nstream\n'),
    ...data,
    ..._ascii('\nendstream'),
  ];
}

String _escapePdfText(String text) {
  return text
      .replaceAll(r'\', r'\\')
      .replaceAll('(', r'\(')
      .replaceAll(')', r'\)');
}

/// Builds a PDF whose pages are, in order, either text pages
/// (`text` non-null) or image-only pages (`text` null).
List<int> buildTestPdf(List<({String? text})> pages) {
  final bodies = <int, List<int>>{};
  var nextObj = 1;
  int alloc() => nextObj++;

  final catalogNum = alloc();
  final pagesNum = alloc();
  final fontNum = alloc();
  final pageNums = <int>[];
  for (final page in pages) {
    final pageNum = alloc();
    final contentNum = alloc();
    pageNums.add(pageNum);
    if (page.text == null) {
      final imageNum = alloc();
      final imageBytes = List<int>.generate(8 * 8 * 3, (_) => 200);
      bodies[pageNum] = _ascii(
        '<< /Type /Page /Parent $pagesNum 0 R /MediaBox [0 0 595 842] '
        '/Resources << /XObject << /Im0 $imageNum 0 R >> >> '
        '/Contents $contentNum 0 R >>',
      );
      bodies[contentNum] = _stream(
        _ascii('q 595 0 0 842 0 0 cm /Im0 Do Q'),
        '<< /Length 28 >>',
      );
      bodies[imageNum] = _stream(
        imageBytes,
        '<< /Type /XObject /Subtype /Image /Width 8 /Height 8 '
        '/ColorSpace /DeviceRGB /BitsPerComponent 8 '
        '/Length ${imageBytes.length} >>',
      );
    } else {
      bodies[pageNum] = _ascii(
        '<< /Type /Page /Parent $pagesNum 0 R /MediaBox [0 0 595 842] '
        '/Resources << /Font << /F1 $fontNum 0 R >> >> '
        '/Contents $contentNum 0 R >>',
      );
      final content =
          'BT /F1 24 Tf 72 720 Td (${_escapePdfText(page.text!)}) Tj ET';
      bodies[contentNum] = _stream(
        _ascii(content),
        '<< /Length ${content.length} >>',
      );
    }
  }
  bodies[catalogNum] = _ascii('<< /Type /Catalog /Pages $pagesNum 0 R >>');
  bodies[pagesNum] = _ascii(
    '<< /Type /Pages /Kids [${pageNums.map((n) => '$n 0 R').join(' ')}] '
    '/Count ${pages.length} >>',
  );
  bodies[fontNum] = _ascii(
    '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>',
  );

  final bytes = <int>[..._ascii('%PDF-1.4\n')];
  final offsets = <int>[0];
  for (var n = 1; n < nextObj; n++) {
    offsets.add(bytes.length);
    bytes.addAll(_ascii('$n 0 obj\n'));
    bytes.addAll(bodies[n]!);
    bytes.addAll(_ascii('\nendobj\n'));
  }
  final xrefPos = bytes.length;
  bytes.addAll(_ascii('xref\n0 $nextObj\n'));
  bytes.addAll(_ascii('0000000000 65535 f \n'));
  for (var n = 1; n < nextObj; n++) {
    bytes.addAll(
      _ascii('${offsets[n].toString().padLeft(10, '0')} 00000 n \n'),
    );
  }
  bytes.addAll(
    _ascii(
      'trailer\n<< /Size $nextObj /Root $catalogNum 0 R >>\n'
      'startxref\n$xrefPos\n%%EOF\n',
    ),
  );
  return bytes;
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('si_buddy_ocr_test');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  Future<String> writePdf(String name, List<int> bytes) async {
    final file = File('${tempDir.path}/$name');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  group('PdfTextExtractor with OCR', () {
    test('uses the text layer and never calls OCR', () async {
      final path = await writePdf(
        'text.pdf',
        buildTestPdf([(text: 'Hello scanned world')]),
      );
      final engine = FakeOcrEngine(result: 'should not be used');
      final extractor = PdfTextExtractor(ocrEngine: engine);
      final texts = await extractor.extractPageTexts(
        path,
        onPageStart: (_, _) {},
        isCancelled: () => false,
      );
      expect(texts, ['Hello scanned world']);
      expect(engine.calls, 0);
    });

    test('OCRs an image-only page', () async {
      final path = await writePdf(
        'scanned.pdf',
        buildTestPdf([(text: null)]),
      );
      final engine = FakeOcrEngine(result: '  Scanned words here  ');
      final extractor = PdfTextExtractor(ocrEngine: engine);
      final texts = await extractor.extractPageTexts(
        path,
        onPageStart: (_, _) {},
        isCancelled: () => false,
      );
      expect(texts, ['Scanned words here']);
      expect(engine.calls, 1);
      // Rendered at 2x scale from a 595x842pt page.
      expect(engine.lastWidth, 1190);
      expect(engine.lastHeight, 1684);
    });

    test('mixed document: text page from the layer, image page via OCR',
        () async {
      final path = await writePdf(
        'mixed.pdf',
        buildTestPdf([(text: 'Real text'), (text: null)]),
      );
      final engine = FakeOcrEngine(result: 'Ocr text');
      final extractor = PdfTextExtractor(ocrEngine: engine);
      final ocrPages = <int>[];
      final texts = await extractor.extractPageTexts(
        path,
        onPageStart: (_, _) {},
        onOcrPageStart: (index, _) => ocrPages.add(index),
        isCancelled: () => false,
      );
      expect(texts, ['Real text', 'Ocr text']);
      expect(engine.calls, 1);
      expect(ocrPages, [1]);
    });

    test('OCR failure leaves the page empty', () async {
      final path = await writePdf(
        'scanned.pdf',
        buildTestPdf([(text: null)]),
      );
      final engine = FakeOcrEngine(throws: true);
      final extractor = PdfTextExtractor(ocrEngine: engine);
      final texts = await extractor.extractPageTexts(
        path,
        onPageStart: (_, _) {},
        isCancelled: () => false,
      );
      expect(texts, ['']);
    });

    test('cancellation stops before the second page', () async {
      final path = await writePdf(
        'two.pdf',
        buildTestPdf([(text: 'Page one'), (text: 'Page two')]),
      );
      final extractor = PdfTextExtractor(ocrEngine: FakeOcrEngine());
      var cancelled = false;
      final texts = await extractor.extractPageTexts(
        path,
        onPageStart: (index, _) {
          if (index == 0) cancelled = true;
        },
        isCancelled: () => cancelled,
      );
      expect(texts, ['Page one']);
    });
  });

  group('DocumentRepositoryImpl with OCR', () {
    late AppDatabase db;
    late Directory storageRoot;

    setUp(() async {
      storageRoot = await Directory(
        '${tempDir.path}/storage',
      ).create();
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('scanned PDF persists with OCR text and reports OCR progress',
        () async {
      final sourcePath = await writePdf(
        'scanned.pdf',
        buildTestPdf([(text: null)]),
      );
      final source = File(sourcePath);
      final engine = FakeOcrEngine(result: 'Ocr content');
      final repository = DocumentRepositoryImpl(
        db: db,
        documentsDirectory: () async => storageRoot,
        pdfExtractor: PdfTextExtractor(ocrEngine: engine),
      );
      final file = FileRef(
        path: sourcePath,
        name: 'scanned.pdf',
        format: DocumentFormat.pdf,
        sizeBytes: await source.length(),
        pageCount: 1,
      );
      final events = await repository.extractText(file).toList();
      expect(events.any((e) => e.ocrActive), isTrue);
      final terminal = events.last;
      expect(terminal.document, isNotNull);
      expect(terminal.document!.hasText, isTrue);
      expect(terminal.document!.fullText, 'Ocr content');
      expect(terminal.document!.sections, ['Ocr content']);
      final saved = await repository.getExtractedDocument(
        terminal.document!.document.id,
      );
      expect(saved?.fullText, 'Ocr content');
    });

    test('text PDF never reports OCR activity', () async {
      final sourcePath = await writePdf(
        'text.pdf',
        buildTestPdf([(text: 'Hello')]),
      );
      final source = File(sourcePath);
      final engine = FakeOcrEngine(result: 'unused');
      final repository = DocumentRepositoryImpl(
        db: db,
        documentsDirectory: () async => storageRoot,
        pdfExtractor: PdfTextExtractor(ocrEngine: engine),
      );
      final file = FileRef(
        path: sourcePath,
        name: 'text.pdf',
        format: DocumentFormat.pdf,
        sizeBytes: await source.length(),
        pageCount: 1,
      );
      final events = await repository.extractText(file).toList();
      expect(events.any((e) => e.ocrActive), isFalse);
      expect(engine.calls, 0);
      expect(events.last.document!.fullText, 'Hello');
    });
  });

  group('routeAfterExtraction', () {
    ExtractedDocument doc({
      required DocumentFormat format,
      required String fullText,
    }) {
      return ExtractedDocument(
        document: Document(
          id: 1,
          title: 'notes',
          originalFileName: 'notes.${format.extension}',
          format: format,
          sizeBytes: 10,
          pageCount: 1,
          folderId: null,
          createdAt: DateTime(2026, 11, 5),
          updatedAt: DateTime(2026, 11, 5),
          storedPath: '/tmp/notes.${format.extension}',
        ),
        fullText: fullText,
        sections: fullText.isEmpty ? const [] : [fullText],
        charCount: fullText.length,
      );
    }

    test('PDF with no text goes to the scanned-PDF screen', () {
      expect(
        routeAfterExtraction(doc(format: DocumentFormat.pdf, fullText: '')),
        AppRoutes.ocr,
      );
    });

    test('PDF with text goes to review', () {
      expect(
        routeAfterExtraction(
          doc(format: DocumentFormat.pdf, fullText: 'hello'),
        ),
        AppRoutes.extractionReview,
      );
    });

    test('PPTX with no text goes to review, not the PDF screen', () {
      expect(
        routeAfterExtraction(doc(format: DocumentFormat.pptx, fullText: '')),
        AppRoutes.extractionReview,
      );
    });
  });
}
