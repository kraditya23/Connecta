import 'dart:async';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageUploadException implements Exception {
  final String message;
  StorageUploadException(this.message);
  @override
  String toString() => message;
}

class SupabaseStorageService {
  static const _bucket = 'profile-assets';

  SupabaseClient get _client => Supabase.instance.client;

  Future<File> _compressImage(File file, {int quality = 80}) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) throw StorageUploadException('Could not read that image file.');

    final compressed = img.encodeJpg(image, quality: quality);
    final tempFile = File(
      '${Directory.systemTemp.path}/${DateTime.now().microsecondsSinceEpoch}.jpg',
    );
    await tempFile.writeAsBytes(compressed);
    return tempFile;
  }

  Future<String> uploadProfilePic(File file, String uid) =>
      _compressAndUpload(file, uid: uid, filename: 'avatar.jpg', quality: 80);

  Future<String> uploadCoverPic(File file, String uid) =>
      _compressAndUpload(file, uid: uid, filename: 'cover.jpg', quality: 70);

  Future<String> _compressAndUpload(
    File file, {
    required String uid,
    required String filename,
    required int quality,
  }) async {
    File? compressedFile;
    try {
      compressedFile = await _compressImage(file, quality: quality);
      final path = '$uid/$filename';
      final bytes = await compressedFile.readAsBytes();

      await _client.storage.from(_bucket).uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
      );

      final url = _client.storage.from(_bucket).getPublicUrl(path);
      // Append a cache-buster so the CDN serves the new image immediately.
      return '$url?v=${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      throw StorageUploadException('Image upload failed: ${e.toString()}');
    } finally {
      if (compressedFile != null) {
        unawaited(_safeDelete(compressedFile));
      }
    }
  }

  Future<void> _safeDelete(File file) async {
    try {
      await file.delete();
    } catch (_) {}
  }
}
