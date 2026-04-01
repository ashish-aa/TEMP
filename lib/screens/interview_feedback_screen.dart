import 'package:flutter/material.dart';

class InterviewFeedbackScreen extends StatelessWidget {
  const InterviewFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Feedback")),
      body: const Center(child: Text("Feedback Screen")),
    );
  }
}
