import 'package:cloud_firestore/cloud_firestore.dart';

/// Utility to ensure no Firestore [Timestamp] objects leak into Hive storage.
/// Hive does not support [Timestamp] natively — all Timestamps must be
/// converted to [DateTime] or milliseconds-epoch [int] before writing.
class HiveSafe {
  /// Recursively converts any [Timestamp] values in a map to their
  /// milliseconds-since-epoch representation ([int]), so the entire map
  /// contains only types that Hive can serialize natively.
  static Map<String, dynamic> sanitizeMap(Map<String, dynamic> map) {
    final result = <String, dynamic>{};
    for (final entry in map.entries) {
      result[entry.key] = _sanitizeValue(entry.value);
    }
    return result;
  }

  /// Recursively converts any [Timestamp] values in a list to safe types.
  static List<dynamic> sanitizeList(List<dynamic> list) {
    return list.map((e) => _sanitizeValue(e)).toList();
  }

  static dynamic _sanitizeValue(dynamic value) {
    if (value is Timestamp) {
      return value.millisecondsSinceEpoch;
    }
    if (value is Map<String, dynamic>) {
      return sanitizeMap(value);
    }
    if (value is List<dynamic>) {
      return sanitizeList(value);
    }
    // For other types (int, double, bool, String, DateTime, null, etc.)
    // Hive supports them natively, so pass through.
    return value;
  }
}
