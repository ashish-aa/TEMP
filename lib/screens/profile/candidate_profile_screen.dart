// KEEP ONLY ONE VERSION (clean)
import 'package:flutter/material.dart';

class CandidateProfileScreen extends StatelessWidget {
  const CandidateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Candidate Profile")),
      body: const Center(child: Text("Profile Screen Working ✅")),
    );
  }
}
