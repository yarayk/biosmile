import 'package:flutter/material.dart';
import 'pages/auth_signin_widget.dart';
import 'pages/auth_signup_widget.dart';
import 'pages/terms_of_service_page.dart';
import 'pages/privacy_policy_page.dart';
import 'pages/photo_page.dart';
import 'pages/exercise_camera_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // подключение базы данных
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wlinnnojuqxbpoeizyvz.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndsaW5ubm9qdXF4YnBvZWl6eXZ6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIyMjE5MTQsImV4cCI6MjA1Nzc5NzkxNH0.-rw_YKxF-IWKWyADQaRdrBZqbxa4REO6TrAiBFmAd50',
  );

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