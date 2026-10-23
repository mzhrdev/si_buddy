import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

/// Builds a real, minimal PPTX file in memory.
///
/// [slides] maps a slide number to its paragraphs; each paragraph is a
/// list of text runs (`a:t` elements). The archive also gets the
/// `ppt/presentation.xml` part a real presentation carries.
Uint8List buildPptx({required Map<int, List<List<String>>> slides}) {
  final archive = Archive();
  archive.addFile(
    ArchiveFile(
      'ppt/presentation.xml',
      _presentationXml.length,
      utf8.encode(_presentationXml),
    ),
  );
  for (final entry in slides.entries) {
    final xml = _slideXml(entry.value);
    archive.addFile(
      ArchiveFile(
        'ppt/slides/slide${entry.key}.xml',
        xml.length,
        utf8.encode(xml),
      ),
    );
  }
  return Uint8List.fromList(ZipEncoder().encode(archive));
}

const _presentationXml =
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n'
    '<p:presentation xmlns:p="http://schemas.openxmlformats.org/'
    'presentationml/2006/main"><p:sldIdLst/></p:presentation>';

String _slideXml(List<List<String>> paragraphs) {
  final buffer = StringBuffer()
    ..write('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n')
    ..write(
      '<p:sld xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" '
      'xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main">'
      '<p:cSld><p:spTree><p:sp><p:txBody>',
    );
  for (final paragraph in paragraphs) {
    buffer.write('<a:p>');
    for (final run in paragraph) {
      buffer.write('<a:r><a:t>${_escape(run)}</a:t></a:r>');
    }
    buffer.write('</a:p>');
  }
  buffer.write('</p:txBody></p:sp></p:spTree></p:cSld></p:sld>');
  return buffer.toString();
}

String _escape(String text) {
  return text
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
}
