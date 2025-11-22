import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/announcement.dart';

class AnnouncementProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<Announcement> _announcements = [];

  List<Announcement> get announcements => _announcements;

  Future<void> fetchAnnouncements() async {
    try {
      final snapshot = await _db
          .collection('announcements')
          .orderBy('createdAt', descending: true)
          .get();

      _announcements = snapshot.docs
          .map((d) => Announcement.fromMap(d.id, d.data()))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Fetch announcements error: $e');
    }
  }

  Future<void> addAnnouncement(String title, String content) async {
    try {
      await _db.collection('announcements').add({
        'title': title,
        'content': content,
        'createdAt': DateTime.now(),
      });
      await fetchAnnouncements();
    } catch (e) {
      debugPrint('Add announcement error: $e');
    }
  }
}
