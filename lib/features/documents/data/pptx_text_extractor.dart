import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

import '../domain/document_failures.dart';

/// Text extraction for PPTX files: a small custom parser over the
/// Office Open XML package.
///
/// A PPTX is a zip archive; each slide lives at `ppt/slides/slideN.xml`
/// and its visible text sits in DrawingML `a:t` runs, grouped by `a:p`
/// paragraphs. Slides are read in numeric order (slide2 before
/// slide10), paragraphs become lines within the slide's text.
class PptxTextExtractor {
  static const _drawingMlNamespace =
      'http://schemas.openxmlformats.org/drawingml/2006/main';
  static final _slidePath = RegExp(r'^ppt/slides/slide(\d+)\.xml$');

  /// Counts the slides of the PPTX in [bytes].
  ///
  /// Throws [CorruptedDocumentException] when [bytes] is not a zip
  /// archive or contains no slides — i.e. not a real presentation.
  int slideCount(Uint8List bytes, {required String fileName}) {
    return _slideFiles(_open(bytes, fileName), fileName).length;
  }

  /// Extracts the text of every slide of the PPTX in [bytes], in
  /// numeric slide order.
  ///
  /// [onSlideStart] is called with the 0-based slide index and the
  /// total slide count before each slide is read. When [isCancelled]
  /// reports true the extraction stops early and returns what it has
  /// so far.
  ///
  /// Throws [CorruptedDocumentException] when the file is not a valid
  /// PPTX or a slide cannot be parsed.
  List<String> extractSlideTexts(
    Uint8List bytes, {
    required String fileName,
    required void Function(int slideIndex, int totalSlides) onSlideStart,
    required bool Function() isCancelled,
  }) {
    final archive = _open(bytes, fileName);
    final slides = _slideFiles(archive, fileName);
    final texts = <String>[];
    for (var i = 0; i < slides.length; i++) {
      if (isCancelled()) return texts;
      onSlideStart(i, slides.length);
      texts.add(_slideText(slides[i], fileName));
    }
    return texts;
  }

  Archive _open(Uint8List bytes, String fileName) {
    try {
      return ZipDecoder().decodeBytes(bytes);
    } on Object {
      throw CorruptedDocumentException(
        fileName: fileName,
        reason: 'Not a zip archive.',
      );
    }
  }

  /// The slide XML files of [archive], ordered by slide number.
  List<ArchiveFile> _slideFiles(Archive archive, String fileName) {
    final matches = <(int, ArchiveFile)>[];
    for (final file in archive.files) {
      final match = _slidePath.firstMatch(file.name);
      if (match != null) matches.add((int.parse(match.group(1)!), file));
    }
    if (matches.isEmpty) {
      throw CorruptedDocumentException(
        fileName: fileName,
        reason: 'No slides found — not a PowerPoint presentation.',
      );
    }
    matches.sort((a, b) => a.$1.compareTo(b.$1));
    return [for (final match in matches) match.$2];
  }

  String _slideText(ArchiveFile slide, String fileName) {
    final XmlDocument document;
    try {
      document = XmlDocument.parse(utf8.decode(slide.content));
    } on Object {
      throw CorruptedDocumentException(
        fileName: fileName,
        reason: 'Slide XML could not be parsed.',
      );
    }
    final paragraphs = <String>[];
    for (final element in document.descendants.whereType<XmlElement>()) {
      if (!_isDrawingMl(element, 'p')) continue;
      final buffer = StringBuffer();
      for (final run in element.descendants.whereType<XmlElement>()) {
        if (_isDrawingMl(run, 't')) buffer.write(run.innerText);
      }
      paragraphs.add(buffer.toString());
    }
    if (paragraphs.isEmpty) {
      // No paragraph structure: fall back to all text runs in order.
      return document.descendants
          .whereType<XmlElement>()
          .where((element) => _isDrawingMl(element, 't'))
          .map((element) => element.innerText)
          .join(' ')
          .trim();
    }
    return paragraphs.join('\n').trim();
  }

  bool _isDrawingMl(XmlElement element, String localName) {
    return element.name.local == localName &&
        element.name.namespaceUri == _drawingMlNamespace;
  }
}
