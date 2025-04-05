import 'package:flutter/material.dart';
import 'package:untitled2/exercise_sections/additional_exercises.dart';
import 'auth_signin_widget.dart';
import 'auth_signup_widget.dart';
import 'terms_of_service_page.dart';
import 'privacy_policy_page.dart';
import 'email_verification_page.dart';
import 'forgot_password_page.dart';
import 'verification_code_page.dart';
import 'reset_password_page.dart';
import 'home_page.dart';
import 'exercise_sections.dart';
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
        '/email-verification': (context) => EmailVerificationPage(),
        '/forgot-password': (context) => ForgotPasswordPage(),
        '/verification-code': (context) => VerificationCodePage(),
        '/reset-password': (context) => ResetPasswordPage(),
        '/home': (context) => HomePage(),
        '/exercise_sections': (context) => ExerciseSectionsPage(),
        '/tongue_1': (context) => Tongue1(),
        '/tongue_2': (context) => Tongue2(),
        '/tongue_3': (context) => Tongue3(),
        '/tongue_exercises': (context) => TongueExercisesPage(),
        '/lips_exercises': (context) => LipsExercisesPage(),
        '/lips_1': (context) => Lips1(),
        '/lips_2': (context) => Lips2(),
        '/lips_3': (context) => Lips3(),
        '/jaw_exercises': (context) => JawExercisesPage(),
        '/jaw_1': (context) => Jaw1(),
        '/jaw_2': (context) => Jaw2(),
        '/jaw_3': (context) => Jaw3(),
        '/face_exercises': (context) => FaceExercisesPage(),
        '/face_1': (context) => Face1(),
        '/face_2': (context) => Face2(),
        '/face_3': (context) => Face3(),
        '/cheeks_exercises': (context) => CheeksExercisesPage(),
        '/cheeks_1': (context) => Cheeks1(),
        '/cheeks_2': (context) => Cheeks2(),
        '/cheeks_3': (context) => Cheeks3(),
        '/additional_exercises': (context) => AdditionalExercisesPage(),
        '/additional_1': (context) => Additional1(),
        '/additional_2': (context) => Additional2(),
        '/additional_3': (context) => Additional3(),

      },
    );
  }
}