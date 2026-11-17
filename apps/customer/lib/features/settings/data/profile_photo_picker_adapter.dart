import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:image_picker/image_picker.dart';
import 'package:tam_customer/features/settings/domain/profile_photo_picker.dart';

/// The platform picker grants access only to the image the user selects.
final class ProfilePhotoPickerAdapter implements ProfilePhotoPicker {
  ProfilePhotoPickerAdapter(this._picker);
  final ImagePicker _picker;

  @override
  Future<Uint8List?> pickPhoto() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
        requestFullMetadata: false,
      );
      if (file == null) return null;
      if (await file.length() > 5 * 1024 * 1024) {
        throw const ProfilePhotoFailure();
      }
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes, targetWidth: 512);
      try {
        final frame = await codec.getNextFrame();
        try {
          final data = await frame.image.toByteData(
            format: ui.ImageByteFormat.png,
          );
          if (data == null || data.lengthInBytes > 5 * 1024 * 1024) {
            throw const ProfilePhotoFailure();
          }
          return Uint8List.fromList(data.buffer.asUint8List());
        } finally {
          frame.image.dispose();
        }
      } finally {
        codec.dispose();
      }
    } catch (_) {
      throw const ProfilePhotoFailure();
    }
  }
}
