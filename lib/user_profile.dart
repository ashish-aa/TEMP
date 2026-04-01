import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Name: ${user?.displayName ?? "N/A"}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              "Email: ${user?.email ?? "N/A"}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),

            /// LOGOUT BUTTON
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();

                if (context.mounted) {
                  Navigator.popUntil(context, (route) => route.isFirst);
                }
              },
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
