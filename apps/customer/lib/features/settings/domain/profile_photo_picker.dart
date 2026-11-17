import 'dart:typed_data';

abstract interface class ProfilePhotoPicker {
  /// Null means the user cancelled. Photos are local and never uploaded here.
  Future<Uint8List?> pickPhoto();
}

class ProfilePhotoFailure implements Exception {
  const ProfilePhotoFailure();
}
