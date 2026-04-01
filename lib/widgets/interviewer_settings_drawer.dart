import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/interviewer_profile_screen.dart';
import '../screens/auth/login_screen.dart';

class InterviewerSettingsDrawer extends StatelessWidget {
  const InterviewerSettingsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drawer Header
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
              borderRadius: BorderRadius.only(topRight: Radius.circular(24)),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white24,
              child: Text(
                "SM",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            accountName: const Text(
              "Sarah Miller",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              authProvider.user?.email ?? "sarah.miller@company.com",
            ),
          ),

          // Menu Items
          _DrawerTile(
            icon: Icons.person_outline,
            title: "Interviewer Info",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const InterviewerProfileScreen(),
                ),
              );
            },
          ),
          _DrawerTile(
            icon: Icons.security_outlined,
            title: "Privacy & Security",
            onTap: () {},
          ),
          _DrawerTile(
            icon: Icons.notifications_none_outlined,
            title: "Notification Settings",
            onTap: () {},
          ),
          const Spacer(),
          const Divider(indent: 20, endIndent: 20),
          _DrawerTile(
            icon: Icons.logout,
            title: "Logout",
            iconColor: Colors.redAccent,
            textColor: Colors.redAccent,
            onTap: () async {
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? const Color(0xFF64748B)),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? const Color(0xFF1E293B),
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }
}
