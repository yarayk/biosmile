import 'package:flutter/material.dart';
import 'auth_signin_widget.dart';
import 'auth_signup_widget.dart';
import 'terms_of_service_page.dart';
import 'privacy_policy_page.dart';
import 'photo_page.dart';
import 'exercise_camera_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => AuthSignInWidget(),
        '/signup': (context) => AuthSignUpWidget(),
        '/terms': (context) => TermsOfServicePage(),
        '/privacy': (context) => PrivacyPolicyPage(),
        '/photo': (context) => ExercisesPage(),
        '/exercise_camera': (context) => ExerciseCameraPage(),
      },
    );
  }
}