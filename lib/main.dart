import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/settings_provider.dart';

import 'screens/auth/login_screen.dart';
import 'screens/candidate_dashboard_screen.dart';
import 'screens/interviewer_dashboard_screen.dart';
import 'screens/profile/profile_form_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppAuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<AppAuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Skill Deck",
            theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: const Color(0xFF2563EB),
              textTheme: GoogleFonts.interTextTheme(),
            ),
            home: _getHome(auth),
          );
        },
      ),
    );
  }

  Widget _getHome(AppAuthProvider auth) {
    if (auth.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (auth.user == null) {
      return const LoginScreen();
    }

    if (auth.userModel == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Loading profile data..."),
            ],
          ),
        ),
      );
    }

    // Check if profile is complete
    if (!auth.userModel!.isProfileComplete) {
      return const ProfileFormScreen();
    }

    if (auth.userModel!.isInterviewer) {
      return const InterviewerDashboardScreen();
    } else {
      return const CandidateDashboardScreen();
    }
  }
}
