import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/user_avatar.dart';
import 'auth/login_screen.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({super.key});

    @override
    Widget build(BuildContext context) {
        final user = FirebaseAuth.instance.currentUser;

        final name = user?.displayName ?? "User";
        final email = user?.email ?? "No Email";

        return Scaffold(
                appBar: AppBar(
                title: const Text("Profile"),
                centerTitle: true,
      ),

        body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                children: [

        /// 👤 AVATAR
            const SizedBox(height: 20),

        UserAvatar(
                name: name,
                radius: 40,
            ),

            const SizedBox(height: 12),

        /// 👤 NAME
        Text(
                name,
                style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

        /// 📧 EMAIL
        Text(
                email,
                style: const TextStyle(
                color: Color(0xFF64748B),
              ),
            ),

            const SizedBox(height: 30),

        /// 📦 INFO CARD
        Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
        BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
                  )
                ],
              ),
        child: Column(
                children: [
        _tile(Icons.person_outline, "Name", name),
                  const Divider(),
                _tile(Icons.email_outlined, "Email", email),
                ],
              ),
            ),

            const Spacer(),

                /// 🚨 LOGOUT BUTTON
                SizedBox(
                        width: double.infinity,
                child: ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
                style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
    }

    /// 🔹 TILE WIDGET
    Widget _tile(IconData icon, String title, String value) {
        return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(icon),
                title: Text(title),
                subtitle: Text(value),
    );
    }

    /// 🔥 LOGOUT CONFIRMATION
    void _showLogoutDialog(BuildContext context) {
        showDialog(
                context: context,
                builder: (_) => AlertDialog(
                title: const Text("Logout"),
                content: const Text("Are you sure you want to logout?"),
                actions: [
        TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
          ),
        ElevatedButton(
                onPressed: () async {
            Navigator.pop(context);

            await FirebaseAuth.instance.signOut();

            if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
                );
            }
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        child: const Text("Logout"),
          ),
        ],
      ),
    );
    }
}