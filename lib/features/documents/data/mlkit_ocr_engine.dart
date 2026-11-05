import 'dart:typed_data';
import 'dart:ui';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'ocr_engine.dart';

/// The real [OcrEngine]: Google ML Kit Latin text recognition.
///
/// The Latin recognizer is bundled on-device — no model download and
/// no internet — so scanned pages are read fully offline, like the
/// rest of the app. A fresh recognizer is created per page and closed
/// afterwards; recognizers hold native resources and must not leak
/// across pages.
class MlKitOcrEngine implements OcrEngine {
  const MlKitOcrEngine();

  @override
  Future<String> recognizePage({
    required Uint8List bgraPixels,
    required int width,
    required int height,
  }) async {
    final recognizer = TextRecognizer(
      script: TextRecognitionScript.latin,
    );
    try {
      final input = InputImage.fromBytes(
        bytes: bgraPixels,
        metadata: InputImageMetadata(
          size: Size(width.toDouble(), height.toDouble()),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.bgra8888,
          bytesPerRow: width * 4,
        ),
      );
      final result = await recognizer.processImage(input);
      return result.text.trim();
    } finally {
      await recognizer.close();
    }
  }
}
