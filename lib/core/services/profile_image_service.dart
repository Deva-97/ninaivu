import 'dart:convert';

import 'package:image_picker/image_picker.dart';

class ProfileImageService {
  ProfileImageService({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  Future<String?> pickImagePath({ImageSource source = ImageSource.gallery}) async {
    final file = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1200,
      imageQuality: 85,
    );
    return file?.path;
  }

  Future<String?> pickProfileImageData({
    ImageSource source = ImageSource.gallery,
  }) async {
    final file = await _imagePicker.pickImage(
      source: source,
      // Keeping profile images compact avoids unnecessary local DB bloat and
      // stays comfortably within Firestore document-size limits.
      maxWidth: 512,
      imageQuality: 65,
    );
    if (file == null) {
      return null;
    }

    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      return null;
    }

    return base64Encode(bytes);
  }

  Future<String?> pickFromGallery() =>
      pickImagePath(source: ImageSource.gallery);

  Future<String?> pickFromCamera() =>
      pickImagePath(source: ImageSource.camera);
}
