import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

enum PolicyDocumentSource { camera, gallery, pdf }

class PolicyDocumentPickerService {
  PolicyDocumentPickerService({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  Future<String?> pickCameraImage() async {
    final image = await _imagePicker.pickImage(source: ImageSource.camera);
    return image?.path;
  }

  Future<String?> pickGalleryImage() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    return image?.path;
  }

  Future<String?> pickPdfFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    return result?.files.single.path;
  }
}
