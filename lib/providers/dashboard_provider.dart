import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dashboard_model.dart';
import '../models/interview_model.dart';
import '../models/user_model.dart';

class DashboardProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  DashboardModel? _data;
  bool _isLoading = false;
  String? _error;

  DashboardModel? get data => _data;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDashboardData(UserModel user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Fetch Stats
      final statsDoc = await _db
          .collection('users')
          .doc(user.id)
          .collection('stats')
          .doc('overview')
          .get();
      DashboardStats stats;
      if (statsDoc.exists) {
        stats = DashboardStats.fromJson(statsDoc.data()!);
      } else {
        stats = DashboardStats(
          interviews: Stat(value: 0, trend: 'No data'),
          performance: Stat(value: '0%', trend: 'No data'),
          feedback: Stat(value: '0/5', trend: 'No data'),
        );
      }

      // 2. Fetch Upcoming Interviews
      final upcomingSnap = await _db
          .collection('interviews')
          .where('userId', isEqualTo: user.id)
          .where('status', isEqualTo: 'pending')
          .orderBy('startTime')
          .limit(5)
          .get();

      final upcomingList = upcomingSnap.docs
          .map(
            (doc) => UpcomingInterview(
              topic: doc['title'] ?? 'Technical Interview',
              stack: doc['position'] ?? 'Developer',
              time: _formatDateTime((doc['startTime'] as Timestamp).toDate()),
            ),
          )
          .toList();

      // 3. Fetch Recorded Interviews
      final recordedSnap = await _db
          .collection('recordings')
          .where('userId', isEqualTo: user.id)
          .orderBy('timestamp', descending: true)
          .limit(5)
          .get();

      final recordedList = recordedSnap.docs
          .map(
            (doc) => RecordedInterview(
              title: doc['title'] ?? 'Interview Session',
              date: _formatDate((doc['timestamp'] as Timestamp).toDate()),
              duration: "${(doc['duration'] ?? 0)}m",
            ),
          )
          .toList();

      _data = DashboardModel(
        user: DashboardUser(firstName: user.firstName, email: user.email),
        stats: stats,
        upcoming: upcomingList,
        recorded: recordedList,
      );
    } catch (e) {
      _error = "Failed to load dashboard: $e";
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _formatDateTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final suffix = dt.hour >= 12 ? "PM" : "AM";
    return "$hour:${dt.minute.toString().padLeft(2, '0')} $suffix";
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return "${months[dt.month - 1]} ${dt.day}";
  }
}
