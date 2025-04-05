import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config.dart';
import 'inserts.dart';

void main() async {
  // подключение базы данных
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: URL_KEY,
    anonKey: ANON_KEY,
  );

  await insertUser('Yaroslav', 'YA.COM');

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