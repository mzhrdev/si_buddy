import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:si_buddy/features/documents/data/pptx_text_extractor.dart';
import 'package:si_buddy/features/documents/domain/document_failures.dart';

import 'pptx_fixture.dart';

void main() {
  final extractor = PptxTextExtractor();

  group('PptxTextExtractor', () {
    test('extracts slide text in numeric slide order', () {
      final bytes = buildPptx(
        slides: {
          1: [
            ['Cells are the basic unit of life.'],
            ['Second line', ' continues here.'],
          ],
          2: [
            ['Inside the cell'],
          ],
          // Slide 10 must sort after slide 2, not before it.
          10: [
            ['The last slide'],
          ],
        },
      );

      expect(extractor.slideCount(bytes, fileName: 'deck.pptx'), 3);
      final texts = extractor.extractSlideTexts(
        bytes,
        fileName: 'deck.pptx',
        onSlideStart: (_, _) {},
        isCancelled: () => false,
      );
      expect(texts, [
        'Cells are the basic unit of life.\nSecond line continues here.',
        'Inside the cell',
        'The last slide',
      ]);
    });

    test('reports progress per slide and honours cancellation', () {
      final bytes = buildPptx(
        slides: {
          1: [
            ['One'],
          ],
          2: [
            ['Two'],
          ],
        },
      );
      final started = <int>[];
      final texts = extractor.extractSlideTexts(
        bytes,
        fileName: 'deck.pptx',
        onSlideStart: (index, total) {
          started.add(index);
          expect(total, 2);
        },
        isCancelled: () => started.isNotEmpty,
      );
      expect(started, [0]);
      expect(texts, ['One']);
    });

    test('a slide without text runs extracts as empty', () {
      final bytes = buildPptx(slides: {1: []});
      final texts = extractor.extractSlideTexts(
        bytes,
        fileName: 'deck.pptx',
        onSlideStart: (_, _) {},
        isCancelled: () => false,
      );
      expect(texts, ['']);
    });

    test('garbage bytes are a corrupted document', () {
      final garbage = Uint8List.fromList(utf8.encode('not a real pptx'));
      expect(
        () => extractor.slideCount(garbage, fileName: 'deck.pptx'),
        throwsA(isA<CorruptedDocumentException>()),
      );
    });

    test('a zip without slides is a corrupted document', () {
      final archive = Archive()
        ..addFile(ArchiveFile('readme.txt', 5, utf8.encode('hello')));
      final zip = Uint8List.fromList(ZipEncoder().encode(archive));
      expect(
        () => extractor.slideCount(zip, fileName: 'deck.pptx'),
        throwsA(isA<CorruptedDocumentException>()),
      );
    });
  });
}
