import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double progress;
  final double performance;
  final double feedbackScore;

  const ProgressBar({
    super.key,
    this.progress = 0.5,
    this.performance = 0.7,
    this.feedbackScore = 0.9,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Interview Progress', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          SizedBox(height: 20),
          Text('Average Performance', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: performance,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
          SizedBox(height: 20),
          Text('Feedback Score', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: feedbackScore,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        ],
      ),
    );
  }
}
