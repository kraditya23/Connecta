import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageUploadException implements Exception {
  final String message;
  StorageUploadException(this.message);
  @override
  String toString() => message;
}

/// Inputs for the background image-processing isolate. Only holds values that
/// can be sent across an isolate boundary (typed data + primitives).
class _ProcessArgs {
  final Uint8List bytes;
  final int maxDimension;
  final int quality;
  const _ProcessArgs(this.bytes, this.maxDimension, this.quality);
}

/// Decodes, downscales and re-encodes an image as JPEG. The long edge is capped
/// at [maxDimension]; aspect ratio is preserved and images already within the
/// cap are not upscaled. Returns null if the bytes can't be decoded.
///
/// Runs via [compute] in a background isolate so the (potentially heavy)
/// decode/resize/encode of a full-resolution phone photo never blocks the UI
/// thread. Must stay a top-level function for [compute] to accept it.
Uint8List? _processImage(_ProcessArgs args) {
  var image = img.decodeImage(args.bytes);
  if (image == null) return null;

  final isLandscape = image.width >= image.height;
  final longEdge = isLandscape ? image.width : image.height;
  if (longEdge > args.maxDimension) {
    image = isLandscape
        ? img.copyResize(image, width: args.maxDimension)
        : img.copyResize(image, height: args.maxDimension);
  }
  return img.encodeJpg(image, quality: args.quality);
}

class SupabaseStorageService {
  static const _bucket = 'profile-assets';

  SupabaseClient get _client => Supabase.instance.client;

  // Display-size-driven caps (see UserCard / EditContactInfo):
  //   • Avatar renders in a CircleAvatar of radius ~60 (≈120px logical, ≈360px
  //     at 3x), so a 512px long edge is already comfortably oversampled.
  //   • Cover renders full-bleed across the card (up to ~1290px wide at 3x on
  //     large phones), so it gets a larger 1280px cap to stay crisp.
  Future<String> uploadProfilePic(File file, String uid) =>
      _compressAndUpload(file, uid: uid, filename: 'avatar.jpg', maxDimension: 512, quality: 85);

  Future<String> uploadCoverPic(File file, String uid) =>
      _compressAndUpload(file, uid: uid, filename: 'cover.jpg', maxDimension: 1280, quality: 80);

  Future<String> _compressAndUpload(
    File file, {
    required String uid,
    required String filename,
    required int maxDimension,
    required int quality,
  }) async {
    try {
      final originalBytes = await file.readAsBytes();
      final processed = await compute(
        _processImage,
        _ProcessArgs(originalBytes, maxDimension, quality),
      );
      if (processed == null) {
        throw StorageUploadException('Could not read that image file.');
      }

      final path = '$uid/$filename';
      await _client.storage.from(_bucket).uploadBinary(
        path,
        processed,
        fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
      );

      final url = _client.storage.from(_bucket).getPublicUrl(path);
      // Append a cache-buster so the CDN serves the new image immediately.
      return '$url?v=${DateTime.now().millisecondsSinceEpoch}';
    } on StorageUploadException {
      rethrow;
    } catch (e) {
      throw StorageUploadException('Image upload failed: ${e.toString()}');
    }
  }
}
