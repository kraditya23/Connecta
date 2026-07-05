import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// A helper for invoking the native "insert/edit contact" UI on Android and iOS.
class NativeContacts {
  static const MethodChannel _channel = MethodChannel('my_app/contacts');

  /// data: a Map<String, dynamic> containing keys like:
  /// -> fullName: String
  /// -> phones: List<String>
  /// -> emails: List<String>
  /// -> organisation: String?
  /// -> jobTitle: String?
  /// -> websites: List<Map<String, String>>
  /// -> location: String?
  /// -> aboutMe: String?
  ///
  /// Returns true if the native UI launched successfully.
  static Future<bool> addOrUpdateContact(Map<String, dynamic> data) async {
    try {
      final bool result = await _channel.invokeMethod('addOrUpdate', data);
      return result;
    } catch (e) {
      debugPrint('NativeContacts error: $e');
      return false;
    }
  }
}