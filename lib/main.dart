import 'package:flutter/material.dart';
<<<<<<< Updated upstream
import 'auth_signin_widget.dart';
import 'auth_signup_widget.dart';
import 'terms_of_service_page.dart';
import 'privacy_policy_page.dart';
import 'photo_page.dart';
import 'exercise_camera_page.dart';
=======
import 'package:untitled2/exercise_sections/additional_exercises.dart';
import 'pages/auth_signin_widget.dart';
import 'pages/auth_signup_widget.dart';
import 'pages/terms_of_service_page.dart';
import 'pages/privacy_policy_page.dart';
import 'pages/email_verification_page.dart';
import 'pages/forgot_password_page.dart';
import 'pages/verification_code_page.dart';
import 'pages/reset_password_page.dart';
import 'pages/home_page.dart';
import 'pages/exercise_sections.dart';
import 'exercise_sections/tongue_exercises.dart';
import 'exercise_sections/lips_exercises.dart';
import 'exercise_sections/lips_exercises/lips_1.dart';
import 'exercise_sections/lips_exercises/lips_2.dart';
import 'exercise_sections/lips_exercises/lips_3.dart';
import 'exercise_sections/tongue_exercises/tongue_1.dart';
import 'exercise_sections/tongue_exercises/tongue_2.dart';
import 'exercise_sections/tongue_exercises/tongue_3.dart';
import 'exercise_sections/jaw_exercises.dart';
import 'exercise_sections/jaw_exercises/jaw_1.dart';
import 'exercise_sections/jaw_exercises/jaw_2.dart';
import 'exercise_sections/jaw_exercises/jaw_3.dart';
import 'exercise_sections/face_exercises.dart';
import 'exercise_sections/face_exercises/face_1.dart';
import 'exercise_sections/face_exercises/face_2.dart';
import 'exercise_sections/face_exercises/face_3.dart';
import 'exercise_sections/cheeks_exercises.dart';
import 'exercise_sections/cheeks_exercises/cheeks_1.dart';
import 'exercise_sections/cheeks_exercises/cheeks_2.dart';
import 'exercise_sections/cheeks_exercises/cheeks_3.dart';
import 'exercise_sections/additional_exercises.dart';
import 'exercise_sections/additional_exercises/additional_1.dart';
import 'exercise_sections/additional_exercises/additional_2.dart';
import 'exercise_sections/additional_exercises/additional_3.dart';
>>>>>>> Stashed changes

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