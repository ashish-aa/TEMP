import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../widgets/settings_modal.dart';
import '../services/database_service.dart';
import '../models/interview_model.dart';
import 'mock_interview_screen.dart';
import 'profile_screen.dart';
import 'candidate_management_screen.dart';
import 'schedule_interview_screen.dart';

class InterviewerDashboardScreen extends StatefulWidget {
  const InterviewerDashboardScreen({super.key});

  @override
  State<InterviewerDashboardScreen> createState() =>
      _InterviewerDashboardScreenState();
}

class _InterviewerDashboardScreenState
    extends State<InterviewerDashboardScreen> {
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
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  "IH",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Skill Deck",
              style: TextStyle(
                color: Color(0xFF1E293B),
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
      body: userId.isEmpty
          ? const Center(child: Text("User not authenticated"))
          : StreamBuilder<List<InterviewModel>>(
              stream: _dbService.streamInterviewsForUser(
                userId,
                isInterviewer: true,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Something went wrong while fetching interviews.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 16,
                            ),
                          ),
                          TextButton(
                            onPressed: () => setState(() {}),
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final allInterviews = snapshot.data ?? [];

                // Calculate stats from real-time data
                final now = DateTime.now();
                final interviewsToday = allInterviews.where((i) {
                  return i.startTime.year == now.year &&
                      i.startTime.month == now.month &&
                      i.startTime.day == now.day;
                }).toList();

                // Average Rating Calculation
                double totalRating = 0;
                int ratingCount = 0;
                for (var interview in allInterviews) {
                  if (interview.feedback != null &&
                      interview.feedback!['score'] != null) {
                    double score = (interview.feedback!['score'] as num)
                        .toDouble();
                    if (score > 5) score = score / 20;
                    totalRating += score;
                    ratingCount++;
                  }
                }
                final avgRating = ratingCount > 0
                    ? totalRating / ratingCount
                    : 0.0;

                return RefreshIndicator(
                  onRefresh: () async => setState(() {}),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome back, ${auth.userModel?.firstName ?? 'Hiring Manager'}!",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Review and manage your candidates in real-time",
                          style: TextStyle(fontSize: 16, color: textGrey),
                        ),
                        const SizedBox(height: 32),

                        // --- Real-time Stats Cards ---
                        _buildStatsCards(
                          interviewsTodayCount: interviewsToday.length,
                          avgRating: avgRating,
                          reviewCount: ratingCount,
                        ),

                        const SizedBox(height: 40),

                        // --- Today's Schedule Section ---
                        _buildScheduleSection(interviewsToday),

                        const SizedBox(height: 40),

                        // --- Pending Reviews Section ---
                        _buildReviewsSection(allInterviews),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStatsCards({
    required int interviewsTodayCount,
    required double avgRating,
    required int reviewCount,
  }) {
    return Column(
      children: [
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: _dbService.streamAllCandidates(),
          builder: (context, snapshot) {
            final count = snapshot.data?.length ?? 0;
            return _buildStatCard(
              title: "Total Candidates",
              value: "$count",
              subtitle: "In talent pool",
              icon: Icons.people_outline,
              iconColor: primaryBlue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CandidateManagementScreen(),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          title: "Interviews Today",
          value: "$interviewsTodayCount",
          subtitle: "Scheduled for today",
          subtitleColor: interviewsTodayCount > 0
              ? const Color(0xFF10B981)
              : textGrey,
          icon: Icons.calendar_today_outlined,
          iconColor: Colors.orange,
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          title: "Avg. Rating",
          value: "${avgRating.toStringAsFixed(1)}/5",
          subtitle: "From $reviewCount reviews",
          icon: Icons.star_outline,
          iconColor: Colors.amber,
        ),
      ],
    );
  }

  Widget _buildScheduleSection(List<InterviewModel> todayInterviews) {
    final upcoming = todayInterviews
        .where(
          (i) =>
              i.status == InterviewStatus.scheduled ||
              i.status == InterviewStatus.ongoing,
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Schedule",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ScheduleInterviewScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              label: const Text("Schedule"),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (upcoming.isEmpty)
          _buildEmptyCard("No interviews scheduled for today")
        else
          ...upcoming.map((i) => _buildScheduleCard(context, interview: i)),
      ],
    );
  }

  Widget _buildReviewsSection(List<InterviewModel> interviews) {
    final reviewNeeded = interviews
        .where(
          (i) => i.status == InterviewStatus.completed && i.feedback == null,
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Pending Reviews",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 20),
        if (reviewNeeded.isEmpty)
          _buildEmptyCard("No reviews pending")
        else
          ...reviewNeeded.map(
            (i) => _buildReviewCard(
              name: i.candidateName,
              role: i.position,
              status: "Pending Evaluation",
              isOrange: true,
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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

  Widget _buildProfileDropdown(BuildContext context, AppAuthProvider auth) {
    final user = auth.userModel;
    final initials = (user != null && user.firstName.isNotEmpty)
        ? user.firstName[0].toUpperCase()
        : "M";

    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
        radius: 18,
        backgroundColor: const Color(0xFF9333EA),
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    Color? iconColor,
    Color? subtitleColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
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
                const SizedBox(height: 12),
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
                  subtitle,
                  style: TextStyle(
                    color: subtitleColor ?? textGrey,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Icon(icon, color: iconColor ?? primaryBlue, size: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(
    BuildContext context, {
    required InterviewModel interview,
  }) {
    final bool isOngoing = interview.status == InterviewStatus.ongoing;
    final timeParts = (interview.timeRange ?? "").split(' - ');
    final startTimeDisplay = (timeParts.isNotEmpty && timeParts[0].isNotEmpty)
        ? timeParts[0]
        : '--:--';

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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    interview.candidateName ?? "Unknown Candidate",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    interview.position ?? "No Position Specified",
                    style: TextStyle(color: textGrey, fontSize: 14),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    startTimeDisplay,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isOngoing
                          ? const Color(0xFFD1FAE5)
                          : const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isOngoing ? "Ongoing" : "Scheduled",
                      style: TextStyle(
                        color: isOngoing
                            ? const Color(0xFF10B981)
                            : primaryBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    "View Portfolio",
                    style: TextStyle(
                      color: textDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    if (interview.status != InterviewStatus.ongoing) {
                      await _dbService.updateInterviewStatus(
                        interview.id,
                        'ongoing',
                      );
                    }
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MockInterviewScreen(
                            roomId: interview.roomId,
                            isInterviewer: true,
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isOngoing ? "Continue" : "Start Interview",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard({
    required String name,
    required String role,
    required String status,
    bool isOrange = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name ?? "Candidate",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textDark,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                role ?? "Role",
                style: TextStyle(color: textGrey, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                status ?? "Not Rated",
                style: TextStyle(
                  color: isOrange ? Colors.orange : const Color(0xFF10B981),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Icon(Icons.rate_review_outlined, color: Colors.blueGrey),
        ],
      ),
    );
  }
}

class _DropdownItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  const _DropdownItem({required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color ?? const Color(0xFF64748B)),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            color: color ?? const Color(0xFF1E293B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
