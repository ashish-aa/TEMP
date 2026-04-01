import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/interview_model.dart';
import '../services/database_service.dart';
import '../widgets/settings_modal.dart';
import 'mock_interview_screen.dart';
import 'profile_screen.dart';

class CandidateDashboardScreen extends StatefulWidget {
  const CandidateDashboardScreen({super.key});

  @override
  State<CandidateDashboardScreen> createState() =>
      _CandidateDashboardScreenState();
}

class _CandidateDashboardScreenState extends State<CandidateDashboardScreen> {
  final DatabaseService _dbService = DatabaseService();
  final Color primaryBlue = const Color(0xFF2563EB);
  final Color backgroundLight = const Color(0xFFF8FAFC);
  final Color textDark = const Color(0xFF1E293B);
  final Color textGrey = const Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AppAuthProvider>(context);
    final userId = auth.user?.uid ?? '';

    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Text(
                "IH",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "Skill Deck",
              style: TextStyle(
                color: textDark,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          _buildProfileDropdown(context, auth),
          const SizedBox(width: 16),
        ],
      ),
      body: StreamBuilder<List<InterviewModel>>(
        stream: _dbService.streamInterviewsForUser(
          userId,
          isInterviewer: false,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Something went wrong while loading data.",
                      style: TextStyle(
                        color: textDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Please check your internet connection and try again.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          final allInterviews = snapshot.data ?? [];
          final upcomingInterviews = allInterviews
              .where(
                (i) =>
                    i.status == InterviewStatus.scheduled ||
                    i.status == InterviewStatus.ongoing,
              )
              .toList();

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back, ${auth.userModel?.firstName ?? 'Alex'}!",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Here's your interview preparation progress",
                  style: TextStyle(fontSize: 16, color: textGrey),
                ),
                const SizedBox(height: 32),

                // Stats Section
                _buildStatsGrid(allInterviews),

                const SizedBox(height: 40),

                // Upcoming Interviews Section
                const Text(
                  "Upcoming Interviews",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 16),

                if (upcomingInterviews.isEmpty)
                  _buildEmptyCard("No upcoming interviews found.")
                else
                  ...upcomingInterviews.map(
                    (interview) => _buildUpcomingCard(context, interview),
                  ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid(List<InterviewModel> interviews) {
    final completed = interviews
        .where((i) => i.status == InterviewStatus.completed)
        .length;
    final active = interviews
        .where(
          (i) =>
              i.status == InterviewStatus.scheduled ||
              i.status == InterviewStatus.ongoing,
        )
        .length;

    return Column(
      children: [
        _buildStatCard(
          title: "Interviews Completed",
          value: completed.toString(),
          trend: "Total sessions",
          icon: Icons.people_outline,
          iconColor: primaryBlue,
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          title: "Active Interviews",
          value: active.toString(),
          trend: "Ready to start",
          icon: Icons.trending_up,
          iconColor: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildUpcomingCard(BuildContext context, InterviewModel interview) {
    final bool isOngoing = interview.status == InterviewStatus.ongoing;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOngoing
              ? primaryBlue.withOpacity(0.3)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    interview.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    interview.position,
                    style: TextStyle(color: textGrey, fontSize: 14),
                  ),
                ],
              ),
              _buildStatusBadge(interview.status),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 16, color: textGrey),
              const SizedBox(width: 8),
              Text(
                interview.timeRange,
                style: TextStyle(color: textDark, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (interview.roomId != null && interview.roomId!.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MockInterviewScreen(
                        roomId: interview.roomId,
                        isInterviewer: false,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Room not ready. Please contact interviewer.",
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.play_arrow_outlined),
              label: Text(isOngoing ? "Continue Interview" : "Start Interview"),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(InterviewStatus status) {
    bool isOngoing = status == InterviewStatus.ongoing;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOngoing ? const Color(0xFFD1FAE5) : const Color(0xFFDBEAFE),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isOngoing ? "Ongoing" : "Scheduled",
        style: TextStyle(
          color: isOngoing ? const Color(0xFF10B981) : primaryBlue,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              color: textGrey.withOpacity(0.5),
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(message, style: TextStyle(color: textGrey, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String trend,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: textGrey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                trend,
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDropdown(BuildContext context, AppAuthProvider auth) {
    final user = auth.userModel;
    final initials = (user != null && user.firstName.isNotEmpty)
        ? user.firstName[0].toUpperCase()
        : "U";

    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'profile') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        } else if (value == 'settings') {
          SettingsModal.show(context, userEmail: user?.email ?? "");
        } else if (value == 'logout') {
          auth.signOut();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'profile', child: Text("Profile")),
        const PopupMenuItem(value: 'settings', child: Text("Settings")),
        const PopupMenuItem(value: 'logout', child: Text("Logout")),
      ],
      child: CircleAvatar(
        backgroundColor: primaryBlue,
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
