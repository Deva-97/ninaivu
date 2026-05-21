import 'dart:io';

class InsuranceDocumentParseResult {
  const InsuranceDocumentParseResult({
    required this.filePath,
    required this.message,
  });

  final String filePath;
  final String message;
}

abstract class InsuranceDocumentParser {
  Future<InsuranceDocumentParseResult> parseDocument(File file);
}

class PlaceholderInsuranceDocumentParser implements InsuranceDocumentParser {
  const PlaceholderInsuranceDocumentParser();

  @override
  Future<InsuranceDocumentParseResult> parseDocument(File file) async {
    return InsuranceDocumentParseResult(
      filePath: file.path,
      message:
          'Automatic insurance detail extraction will be added in a future update.',
    );
  }
}
