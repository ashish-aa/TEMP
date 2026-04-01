class DashboardModel {
  final DashboardUser user;
  final DashboardStats stats;
  final List<UpcomingInterview> upcoming;
  final List<RecordedInterview> recorded;

  DashboardModel({
    required this.user,
    required this.stats,
    required this.upcoming,
    required this.recorded,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      user: DashboardUser.fromJson(json['user'] ?? {}),
      stats: DashboardStats.fromJson(json['dashboardStats'] ?? {}),
      upcoming: (json['upcomingInterviews'] as List? ?? [])
          .map((e) => UpcomingInterview.fromJson(e))
          .toList(),
      recorded: (json['recordedInterviews'] as List? ?? [])
          .map((e) => RecordedInterview.fromJson(e))
          .toList(),
    );
  }
}

class DashboardUser {
  final String firstName;
  final String email;

  DashboardUser({required this.firstName, required this.email});

  factory DashboardUser.fromJson(Map<String, dynamic> json) {
    return DashboardUser(
      firstName: json['firstName'] ?? 'User',
      email: json['email'] ?? '',
    );
  }
}

class DashboardStats {
  final Stat interviews;
  final Stat performance;
  final Stat feedback;

  DashboardStats({
    required this.interviews,
    required this.performance,
    required this.feedback,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      interviews: Stat.fromJson(json['interviewsCompleted'] ?? {}),
      performance: Stat.fromJson(json['averagePerformance'] ?? {}),
      feedback: Stat.fromJson(json['feedbackScore'] ?? {}),
    );
  }
}

class Stat {
  final dynamic value;
  final String trend;

  Stat({required this.value, required this.trend});

  factory Stat.fromJson(Map<String, dynamic> json) {
    return Stat(value: json['value'] ?? 0, trend: json['trendText'] ?? '');
  }
}

class UpcomingInterview {
  final String topic;
  final String stack;
  final String time;

  UpcomingInterview({
    required this.topic,
    required this.stack,
    required this.time,
  });

  factory UpcomingInterview.fromJson(Map<String, dynamic> json) {
    return UpcomingInterview(
      topic: json['topic'] ?? 'Technical Interview',
      stack: json['stack'] ?? 'Developer',
      time: json['time'] ?? '',
    );
  }
}

class RecordedInterview {
  final String title;
  final String date;
  final String duration;

  RecordedInterview({
    required this.title,
    required this.date,
    required this.duration,
  });

  factory RecordedInterview.fromJson(Map<String, dynamic> json) {
    return RecordedInterview(
      title: json['title'] ?? 'Recorded Session',
      date: json['date'] ?? '',
      duration: json['duration'] ?? '',
    );
  }
}
