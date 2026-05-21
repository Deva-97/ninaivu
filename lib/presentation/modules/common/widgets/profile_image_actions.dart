import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ninaivu/core/constants/translation_keys.dart';
import 'package:ninaivu/core/widgets/profile_avatar.dart';

Future<void> showProfileImageViewer({
  required BuildContext context,
  required String name,
  String? imagePath,
  String? imageData,
}) async {
  await showDialog<void>(
    context: context,
    builder: (_) => _ProfileImageViewer(
      name: name,
      imagePath: imagePath,
      imageData: imageData,
    ),
  );
}

Future<void> showSettingsProfileImageOptions({
  required BuildContext context,
  required String name,
  String? imagePath,
  String? imageData,
  required Future<void> Function(ImageSource source) onPickImage,
  required Future<void> Function() onRemoveImage,
}) async {
  final hasImage = ProfileAvatar.buildImageProvider(
        imageData: imageData,
        imagePath: imagePath,
      ) !=
      null;

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.visibility_outlined),
              title: Text(TranslationKeys.viewImage.tr),
              enabled: hasImage,
              onTap: hasImage
                  ? () async {
                      Navigator.of(sheetContext).pop();
                      await showProfileImageViewer(
                        context: context,
                        name: name,
                        imagePath: imagePath,
                        imageData: imageData,
                      );
                    }
                  : null,
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(TranslationKeys.takePhoto.tr),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await onPickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(TranslationKeys.chooseFromGallery.tr),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await onPickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded),
              title: Text(TranslationKeys.removePhoto.tr),
              enabled: hasImage,
              onTap: hasImage
                  ? () async {
                      Navigator.of(sheetContext).pop();
                      await onRemoveImage();
                    }
                  : null,
            ),
          ],
        ),
      );
    },
  );
}

class _ProfileImageViewer extends StatelessWidget {
  const _ProfileImageViewer({
    required this.name,
    this.imagePath,
    this.imageData,
  });

  final String name;
  final String? imagePath;
  final String? imageData;

  @override
  Widget build(BuildContext context) {
    final imageProvider = ProfileAvatar.buildImageProvider(
      imageData: imageData,
      imagePath: imagePath,
    );

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: imageProvider != null
                    ? InteractiveViewer(
                        child: Image(
                          image: imageProvider,
                          fit: BoxFit.contain,
                        ),
                      )
                    : ProfileAvatar(
                        name: name,
                        imagePath: imagePath,
                        imageData: imageData,
                        radius: 52,
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
