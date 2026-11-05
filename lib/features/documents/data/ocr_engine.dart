import 'dart:typed_data';

/// Seam over on-device OCR (optical character recognition).
///
/// The PDF extractor renders pages that have no text layer and reads
/// them through this seam, mirroring the engine seam the AI
/// generation feature runs on: the real implementation is a thin
/// wrapper over a platform plugin, and tests substitute a fake.
///
/// Implementations throw on recognition failure; callers treat a
/// failure as "no text on this page" and keep the extraction going.
abstract class OcrEngine {
  /// Recognizes the text in one rendered page image.
  ///
  /// [bgraPixels] is the page's raw BGRA8888 pixel data
  /// ([width] × [height] × 4 bytes), as produced by pdfrx's page
  /// renderer. Returns the recognized text, trimmed; an empty string
  /// when nothing readable was found.
  Future<String> recognizePage({
    required Uint8List bgraPixels,
    required int width,
    required int height,
  });
}
