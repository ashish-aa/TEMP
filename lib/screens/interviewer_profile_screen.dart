import 'package:flutter/material.dart';

class InterviewerProfileScreen extends StatelessWidget {
  const InterviewerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Interviewer Profile")),
      body: const Center(child: Text("Interviewer Profile Screen")),
    );
  }
}
