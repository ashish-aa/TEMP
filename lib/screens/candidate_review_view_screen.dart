import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CandidateReviewViewScreen extends StatelessWidget {
  final String candidateName;

  const CandidateReviewViewScreen({super.key, required this.candidateName});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2563EB);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Interview Feedback",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1E293B),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('feedbacks')
            .where('candidateName', isEqualTo: candidateName)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No feedback available yet."));
          }

          final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
          final ratings = data['ratings'] as Map<String, dynamic>? ?? {};
          final double overallRating = (data['overallRating'] ?? 0.0)
              .toDouble();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section 1: Candidate Info
                _SectionTitle(title: "Candidate Information"),
                _InfoCard(
                  children: [
                    _InfoRow(label: "Candidate Name", value: candidateName),
                    _InfoRow(
                      label: "Position Applied",
                      value: data['position'] ?? "N/A",
                    ),
                    const _InfoRow(
                      label: "Interview Date",
                      value: "Oct 24, 2023",
                      isLast: true,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Section 2: Ratings
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SectionTitle(title: "Performance Ratings"),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Overall: ${overallRating.toStringAsFixed(1)}/5",
                        style: const TextStyle(
                          color: primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _ViewRatingRow(
                  label: "Technical Skills",
                  rating: (ratings['technical'] ?? 0).toDouble(),
                ),
                _ViewRatingRow(
                  label: "Communication",
                  rating: (ratings['communication'] ?? 0).toDouble(),
                ),
                _ViewRatingRow(
                  label: "Problem Solving",
                  rating: (ratings['problemSolving'] ?? 0).toDouble(),
                ),
                _ViewRatingRow(
                  label: "Culture Fit",
                  rating: (ratings['cultureFit'] ?? 0).toDouble(),
                ),

                const SizedBox(height: 24),

                // Section 3: Detailed Feedback
                _SectionTitle(title: "Detailed Feedback"),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Text(
                    data['comments'] ?? "No comments provided.",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF475569),
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Section 4: Decision
                _SectionTitle(title: "Hiring Decision"),
                _DecisionBadge(decision: data['decision'] ?? "pending"),

                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Close",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ViewRatingRow extends StatelessWidget {
  final String label;
  final double rating;
  const _ViewRatingRow({required this.label, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          ...List.generate(
            5,
            (index) => Icon(
              index < rating ? Icons.star : Icons.star_border,
              color: index < rating ? Colors.amber : Colors.grey.shade300,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "${rating.toInt()}/5",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _DecisionBadge extends StatelessWidget {
  final String decision;
  const _DecisionBadge({required this.decision});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    switch (decision) {
      case 'strong_yes':
        color = Colors.green;
        text = "Strong Yes";
        break;
      case 'yes':
        color = Colors.blue;
        text = "Yes";
        break;
      case 'maybe':
        color = Colors.orange;
        text = "Maybe";
        break;
      case 'no':
        color = Colors.red;
        text = "No";
        break;
      default:
        color = Colors.grey;
        text = "Pending";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1E293B),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          if (!isLast) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
          ],
        ],
      ),
    );
  }
}
