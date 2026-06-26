import 'package:cloud_firestore/cloud_firestore.dart';

import 'hive_service.dart';

class AdminNotificationSyncService {
  AdminNotificationSyncService._();

  static final _firestore = FirebaseFirestore.instance;

  static Future<int> syncLatest() async {
    final snapshot = await _firestore
        .collection('admin_notifications')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    var added = 0;
    for (final doc in snapshot.docs.reversed) {
      final data = doc.data();
      final targetRole = (data['targetRole'] as String?) ?? 'student';
      if (targetRole != 'student' && targetRole != 'all') continue;

      final title = (data['title'] as String?)?.trim() ?? '';
      final body = (data['body'] as String?)?.trim() ?? '';
      if (title.isEmpty || body.isEmpty) continue;

      final createdAt = data['createdAt'];
      final receivedAt = createdAt is Timestamp
          ? createdAt.toDate()
          : DateTime.now();
      final localId = 'admin_${doc.id}';

      final didSave = await HiveService.saveNotificationToHistoryIfNew({
        'id': localId,
        'title': title,
        'body': body,
        'type': 'admin_announcement',
        'receivedAt': receivedAt.toIso8601String(),
        'isRead': false,
        'payload': doc.id,
      });

      if (didSave) added++;
    }

    return added;
  }
}
