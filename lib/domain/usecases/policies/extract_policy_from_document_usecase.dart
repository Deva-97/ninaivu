import 'package:ninaivu/core/constants/translation_keys.dart';
import 'package:ninaivu/core/services/policy_document_extraction_exception.dart';
import 'package:ninaivu/core/services/policy_document_picker_service.dart';
import 'package:ninaivu/core/services/policy_document_prefill_service.dart';
import 'package:ninaivu/core/services/policy_text_extraction_service.dart';
import 'package:ninaivu/domain/entities/extracted_policy_data.dart';

class ExtractPolicyFromDocumentUseCase {
  ExtractPolicyFromDocumentUseCase(
    this._pickerService,
    this._textExtractionService,
    this._prefillService,
  );

  final PolicyDocumentPickerService _pickerService;
  final PolicyTextExtractionService _textExtractionService;
  final PolicyDocumentPrefillService _prefillService;

  Future<ExtractedPolicyData?> call(PolicyDocumentSource source) async {
    final path = await _pickPath(source);
    if (path == null || path.isEmpty) {
      return null;
    }

    final rawText = await _extractText(source, path);
    if (rawText.trim().isEmpty) {
      throw PolicyDocumentExtractionException(
        messageKey: source == PolicyDocumentSource.pdf
            ? TranslationKeys.scannedPdfNotSupportedYet
            : TranslationKeys.noReadableTextFound,
        detailKey: source == PolicyDocumentSource.pdf
            ? null
            : TranslationKeys.pleaseTryClearerImage,
      );
    }

    return _prefillService.parse(rawText);
  }

  Future<String?> _pickPath(PolicyDocumentSource source) {
    switch (source) {
      case PolicyDocumentSource.camera:
        return _pickerService.pickCameraImage();
      case PolicyDocumentSource.gallery:
        return _pickerService.pickGalleryImage();
      case PolicyDocumentSource.pdf:
        return _pickerService.pickPdfFile();
    }
  }

  Future<String> _extractText(PolicyDocumentSource source, String path) async {
    try {
      if (source == PolicyDocumentSource.pdf) {
        return await _textExtractionService.extractTextFromPdfPath(path);
      }
      return await _textExtractionService.extractTextFromImagePath(path);
    } catch (_) {
      throw const PolicyDocumentExtractionException(
        messageKey: TranslationKeys.couldNotReadDocument,
      );
    }
  }
}
