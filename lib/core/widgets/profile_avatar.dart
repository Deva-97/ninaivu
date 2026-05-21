import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.name,
    this.imagePath,
    this.imageData,
    this.radius = 28,
    this.onTap,
  });

  final String name;
  final String? imagePath;
  final String? imageData;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final imageProvider = buildImageProvider(
      imageData: imageData,
      imagePath: imagePath,
    );
    final child = CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? Text(
              _initials(name),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
    );

    if (onTap == null) {
      return child;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(radius + 8),
      onTap: onTap,
      child: child,
    );
  }

  static ImageProvider<Object>? buildImageProvider({
    String? imageData,
    String? imagePath,
  }) {
    if (imageData != null && imageData.trim().isNotEmpty) {
      try {
        return MemoryImage(base64Decode(imageData));
      } catch (_) {
        // Fall back to older file-based avatars if the encoded data is invalid.
      }
    }
    if (imagePath == null || imagePath.trim().isEmpty) {
      return null;
    }
    final file = File(imagePath);
    if (!file.existsSync()) {
      return null;
    }
    return FileImage(file);
  }

  static Uint8List? decodeImageData(String? imageData) {
    if (imageData == null || imageData.trim().isEmpty) {
      return null;
    }
    try {
      return base64Decode(imageData);
    } catch (_) {
      return null;
    }
  }

  String _initials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}
