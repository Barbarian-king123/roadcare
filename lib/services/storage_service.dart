import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads an issue photo to Firebase Storage and returns its public download URL.
  /// Supports both Web and Mobile via raw bytes [Uint8List] or [XFile].
  Future<String?> uploadIssueImage({
    required XFile imageFile,
    String? customPath,
  }) async {
    try {
      final Uint8List bytes = await imageFile.readAsBytes();
      final String extension = imageFile.name.split('.').last.toLowerCase();
      final String mimeType = extension == 'png' ? 'image/png' : 'image/jpeg';
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String path = customPath ?? 'issues/issue_$timestamp.$extension';

      final Reference ref = _storage.ref().child(path);
      final SettableMetadata metadata = SettableMetadata(
        contentType: mimeType,
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      final UploadTask uploadTask = ref.putData(bytes, metadata);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      // In case Firebase Storage is offline or rules blocked
      return null;
    }
  }

  /// Uploads a user avatar image to Firebase Storage and returns its download URL.
  Future<String?> uploadAvatar({
    required String userId,
    required XFile imageFile,
  }) async {
    try {
      final Uint8List bytes = await imageFile.readAsBytes();
      final String extension = imageFile.name.split('.').last.toLowerCase();
      final String mimeType = extension == 'png' ? 'image/png' : 'image/jpeg';
      final String path = 'avatars/avatar_$userId.$extension';

      final Reference ref = _storage.ref().child(path);
      final SettableMetadata metadata = SettableMetadata(contentType: mimeType);

      final UploadTask uploadTask = ref.putData(bytes, metadata);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      return null;
    }
  }
}
