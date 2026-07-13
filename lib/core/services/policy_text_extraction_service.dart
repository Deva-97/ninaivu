import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PolicyTextExtractionService {
  const PolicyTextExtractionService();

  Future<String> extractTextFromImagePath(String path) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final inputImage = InputImage.fromFilePath(path);
      final result = await recognizer.processImage(inputImage);
      final lineTexts = <String>[];
      for (final block in result.blocks) {
        for (final line in block.lines) {
          final text = line.text.trim();
          if (text.isNotEmpty) {
            lineTexts.add(text);
          }
        }
      }

      if (lineTexts.isNotEmpty) {
        final text = _collapseAdjacentDuplicates(lineTexts).join('\n').trim();
        if (kDebugMode) {
          debugPrint('Policy OCR lines:\n$text');
        }
        return text;
      }

      final text = result.text.trim();
      if (kDebugMode) {
        debugPrint('Policy OCR raw text:\n$text');
      }
      return text;
    } finally {
      await recognizer.close();
    }
  }

  Future<String> extractTextFromPdfPath(String path) async {
    final document = PdfDocument(inputBytes: await File(path).readAsBytes());
    try {
      final text = PdfTextExtractor(document).extractText().trim();
      if (kDebugMode) {
        debugPrint('Policy PDF extracted text:\n$text');
      }
      return text;
    } finally {
      document.dispose();
    }
  }

  List<String> _collapseAdjacentDuplicates(List<String> lines) {
    final deduped = <String>[];
    String? previous;

    for (final line in lines) {
      if (line == previous) {
        continue;
      }
      deduped.add(line);
      previous = line;
    }

    return deduped;
  }
}
