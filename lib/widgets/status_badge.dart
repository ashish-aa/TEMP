import 'package:flutter/material.dart';

enum CandidateStatus {
  hired,
  pending,
  rejected,
  interview,
}

class StatusBadge extends StatelessWidget {
  final CandidateStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (status) {
      case CandidateStatus.hired:
        color = Colors.green;
        text = 'Hired';
        break;
      case CandidateStatus.pending:
        color = Colors.orange;
        text = 'Pending';
        break;
      case CandidateStatus.rejected:
        color = Colors.red;
        text = 'Rejected';
        break;
      case CandidateStatus.interview:
        color = Colors.blue;
        text = 'Interview';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
