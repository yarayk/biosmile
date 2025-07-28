import 'package:untitled2/exercise_sections/additional_exercises.dart';
import 'pages/auth_signin_widget.dart';
import 'pages/auth_signup_widget.dart';
import 'pages/terms_of_service_page.dart';
import 'pages/privacy_policy_page.dart';
import 'pages/email_verification_page.dart';
import 'pages/forgot_password_page.dart';
import 'pages/password_page.dart';
import 'pages/reset_password_page.dart';
import 'pages/home_page.dart';
import 'pages/exercise_sections.dart';
import 'pages/photo_diary_page.dart';
import 'pages/profile_page.dart';
import 'pages/Photo.dart';
import 'pages/hall_of_fame.dart';
import 'pages/settings_page.dart';
import 'exercise_sections/tongue_exercises.dart';
import 'exercise_sections/lips_exercises.dart';
import 'exercise_sections/lips_exercises/lips_1.dart';
import 'exercise_sections/lips_exercises/lips_2.dart';
import 'exercise_sections/lips_exercises/lips_3.dart';
import 'exercise_sections/lips_exercises/lips_4.dart';
import 'exercise_sections/lips_exercises/lips_5.dart';
import 'exercise_sections/lips_exercises/lips_6.dart';
import 'exercise_sections/lips_exercises/lips_7.dart';
import 'exercise_sections/tongue_exercises/tongue_1.dart';
import 'exercise_sections/tongue_exercises/tongue_2.dart';
import 'exercise_sections/tongue_exercises/tongue_3.dart';
import 'exercise_sections/tongue_exercises/tongue_4.dart';
import 'exercise_sections/tongue_exercises/tongue_5.dart';
import 'exercise_sections/tongue_exercises/tongue_6.dart';
import 'exercise_sections/tongue_exercises/tongue_7.dart';
import 'exercise_sections/jaw_exercises.dart';
import 'exercise_sections/jaw_exercises/jaw_1.dart';
import 'exercise_sections/jaw_exercises/jaw_2.dart';
import 'exercise_sections/jaw_exercises/jaw_3.dart';
import 'exercise_sections/face_exercises.dart';
import 'exercise_sections/face_exercises/face_1.dart';
import 'exercise_sections/face_exercises/face_2.dart';
import 'exercise_sections/face_exercises/face_3.dart';
import 'exercise_sections/face_exercises/face_4.dart';
import 'exercise_sections/face_exercises/face_5.dart';
import 'exercise_sections/face_exercises/face_6.dart';
import 'exercise_sections/face_exercises/face_7.dart';
import 'exercise_sections/face_exercises/face_8.dart';
import 'exercise_sections/face_exercises/face_9.dart';
import 'exercise_sections/face_exercises/face_10.dart';
import 'exercise_sections/face_exercises/face_11.dart';
import 'exercise_sections/face_exercises/face_12.dart';
import 'exercise_sections/face_exercises/face_13.dart';
import 'exercise_sections/face_exercises/face_14.dart';
import 'exercise_sections/face_exercises/face_15.dart';
import 'exercise_sections/cheeks_exercises.dart';
import 'exercise_sections/cheeks_exercises/cheeks_1.dart';
import 'exercise_sections/cheeks_exercises/cheeks_2.dart';
import 'exercise_sections/cheeks_exercises/cheeks_3.dart';
import 'exercise_sections/cheeks_exercises/cheeks_4.dart';
import 'exercise_sections/cheeks_exercises/cheeks_5.dart';
import 'exercise_sections/additional_exercises.dart';
import 'exercise_sections/additional_exercises/additional_1.dart';
import 'exercise_sections/additional_exercises/additional_2.dart';
import 'exercise_sections/additional_exercises/additional_3.dart';
import 'exercise_sections/additional_exercises/additional_4.dart';

import 'exercise_sections/face_exercises/face_1_exercises.dart';
import 'exercise_sections/face_exercises/face_2_exercises.dart';
import 'exercise_sections/face_exercises/face_3_exercises.dart';
import 'exercise_sections/face_exercises/face_4_exercises.dart';
import 'exercise_sections/face_exercises/face_5_exercises.dart';
import 'exercise_sections/face_exercises/face_6_exercises.dart';
import 'exercise_sections/face_exercises/face_7_exercises.dart';
import 'exercise_sections/face_exercises/face_8_exercises.dart';
import 'exercise_sections/face_exercises/face_9_exercises.dart';
import 'exercise_sections/face_exercises/face_10_exercises.dart';
import 'exercise_sections/face_exercises/face_11_exercises.dart';
import 'exercise_sections/face_exercises/face_12_exercises.dart';
import 'exercise_sections/face_exercises/face_13_exercises.dart';
import 'exercise_sections/face_exercises/face_14_exercises.dart';
import 'exercise_sections/face_exercises/face_15_exercises.dart';
import 'exercise_sections/jaw_exercises/jaw_1_exercises.dart';
import 'exercise_sections/jaw_exercises/jaw_2_exercises.dart';
import 'exercise_sections/jaw_exercises/jaw_3_exercises.dart';
import 'exercise_sections/additional_exercises/additional_1_exercises.dart';
import 'exercise_sections/additional_exercises/additional_2_exercises.dart';
import 'exercise_sections/additional_exercises/additional_3_exercises.dart';
import 'exercise_sections/additional_exercises/additional_4_exercises.dart';
import 'exercise_sections/cheeks_exercises/cheeks_1_exercises.dart';
import 'exercise_sections/cheeks_exercises/cheeks_2_exercises.dart';
import 'exercise_sections/cheeks_exercises/cheeks_3_exercises.dart';
import 'exercise_sections/cheeks_exercises/cheeks_4_exercises.dart';
import 'exercise_sections/cheeks_exercises/cheeks_5_exercises.dart';
import 'exercise_sections/lips_exercises/lips_1_exercises.dart';
import 'exercise_sections/lips_exercises/lips_2_exercises.dart';
import 'exercise_sections/lips_exercises/lips_3_exercises.dart';
import 'exercise_sections/lips_exercises/lips_4_exercises.dart';
import 'exercise_sections/lips_exercises/lips_5_exercises.dart';
import 'exercise_sections/lips_exercises/lips_6_exercises.dart';
import 'exercise_sections/lips_exercises/lips_7_exercises.dart';
import 'exercise_sections/tongue_exercises/tongue_1_exercises.dart';
import 'exercise_sections/tongue_exercises/tongue_2_exercises.dart';
import 'exercise_sections/tongue_exercises/tongue_3_exercises.dart';
import 'exercise_sections/tongue_exercises/tongue_4_exercises.dart';
import 'exercise_sections/tongue_exercises/tongue_5_exercises.dart';
import 'exercise_sections/tongue_exercises/tongue_6_exercises.dart';
import 'exercise_sections/tongue_exercises/tongue_7_exercises.dart';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config.dart';
import 'package:intl/date_symbol_data_local.dart'; // Для локализации календаря
import 'deep_link_handler.dart';
import "game_scripts.dart";

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// контрольная точка 1
void main() async{
  // подключение базы данных
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final context = WidgetsBinding.instance.window;
  });
  await Supabase.initialize(
    url: URL_KEY,
    anonKey: ANON_KEY,
  );
  await initializeDateFormatting('ru_RU', null); // Инициализация локализации для календаря

  // Обработка deep link (восстановление пароля)
  Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
    final AuthChangeEvent event = data.event;
    final Session? session = data.session;

    if (event == AuthChangeEvent.passwordRecovery && session != null) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/password-page',
            (route) => false,
      );
    }

    // После входа через Google (или любой вход)
    if (event == AuthChangeEvent.signedIn && session != null) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/home',
            (route) => false,
      );
    }

  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
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
        '/password-page': (context) => ChangePasswordPage(),
        '/reset-password': (context) => ResetPasswordPage(),
        '/home': (context) => HomePage(),
        '/exercise_sections': (context) => ExerciseSectionsPage(),
        '/profile': (context) => ProfilePage(),
        '/hall': (context) => HallOfFamePage(),
        '/photo': (context) => CameraExerciseScreen(),
        '/photo_diary': (context) => PhotoDiaryPage(),
        '/settings': (context) => SettingsPage(),
        '/tongue_1': (context) => Tongue1(),
        '/tongue_2': (context) => Tongue2(),
        '/tongue_3': (context) => Tongue3(),
        '/tongue_4': (context) => Tongue4(),
        '/tongue_5': (context) => Tongue5(),
        '/tongue_6': (context) => Tongue6(),
        '/tongue_7': (context) => Tongue7(),
        '/tongue_exercises': (context) => TongueExercisesPage(),
        '/lips_exercises': (context) => LipsExercisesPage(),
        '/lips_1': (context) => Lips1(),
        '/lips_2': (context) => Lips2(),
        '/lips_3': (context) => Lips3(),
        '/lips_4': (context) => Lips4(),
        '/lips_5': (context) => Lips5(),
        '/lips_6': (context) => Lips6(),
        '/lips_7': (context) => Lips7(),
        '/jaw_exercises': (context) => JawExercisesPage(),
        '/jaw_1': (context) => Jaw1(),
        '/jaw_2': (context) => Jaw2(),
        '/jaw_3': (context) => Jaw3(),
        '/face_exercises': (context) => FaceExercisesPage(),
        '/face_1': (context) => Face1(),
        '/face_2': (context) => Face2(),
        '/face_3': (context) => Face3(),
        '/face_4': (context) => Face4(),
        '/face_5': (context) => Face5(),
        '/face_6': (context) => Face6(),
        '/face_7': (context) => Face7(),
        '/face_8': (context) => Face8(),
        '/face_9': (context) => Face9(),
        '/face_10': (context) => Face10(),
        '/face_11': (context) => Face11(),
        '/face_12': (context) => Face12(),
        '/face_13': (context) => Face13(),
        '/face_14': (context) => Face14(),
        '/face_15': (context) => Face15(),
        '/cheeks_exercises': (context) => CheeksExercisesPage(),
        '/cheeks_1': (context) => Cheeks1(),
        '/cheeks_2': (context) => Cheeks2(),
        '/cheeks_3': (context) => Cheeks3(),
        '/cheeks_5': (context) => Cheeks4(),
        '/cheeks_4': (context) => Cheeks5(),
        '/additional_exercises': (context) => AdditionalExercisesPage(),
        '/additional_1': (context) => Additional1(),
        '/additional_2': (context) => Additional2(),
        '/additional_3': (context) => Additional3(),
        '/additional_4': (context) => Additional4(),
        '/face_1_exercises': (context) => Face1Exercises(),
        '/face_2_exercises': (context) => Face2Exercises(),
        '/face_3_exercises': (context) => Face3Exercises(),
        '/face_4_exercises': (context) => Face4Exercises(),
        '/face_5_exercises': (context) => Face5Exercises(),
        '/face_6_exercises': (context) => Face6Exercises(),
        '/face_7_exercises': (context) => Face7Exercises(),
        '/face_8_exercises': (context) => Face8Exercises(),
        '/face_9_exercises': (context) => Face9Exercises(),
        '/face_10_exercises': (context) => Face10Exercises(),
        '/face_11_exercises': (context) => Face11Exercises(),
        '/face_12_exercises': (context) => Face12Exercises(),
        '/face_13_exercises': (context) => Face13Exercises(),
        '/face_14_exercises': (context) => Face14Exercises(),
        '/face_15_exercises': (context) => Face15Exercises(),
        '/jaw_1_exercises': (context) => Jaw1Exercises(),
        '/jaw_2_exercises': (context) => Jaw2Exercises(),
        '/jaw_3_exercises': (context) => Jaw3Exercises(),
        '/additional_1_exercises': (context) => Additional1Exercises(),
        '/additional_2_exercises': (context) => Additional2Exercises(),
        '/additional_3_exercises': (context) => Additional3Exercises(),
        '/additional_4_exercises': (context) => Additional4Exercises(),
        '/cheeks_1_exercises': (context) => Cheeks1Exercises(),
        '/cheeks_2_exercises': (context) => Cheeks2Exercises(),
        '/cheeks_3_exercises': (context) => Cheeks3Exercises(),
        '/cheeks_5_exercises': (context) => Cheeks4Exercises(),
        '/cheeks_4_exercises': (context) => Cheeks5Exercises(),
        '/lips_1_exercises': (context) => Lips1Exercises(),
        '/lips_2_exercises': (context) => Lips2Exercises(),
        '/lips_3_exercises': (context) => Lips3Exercises(),
        '/lips_4_exercises': (context) => Lips4Exercises(),
        '/lips_5_exercises': (context) => Lips5Exercises(),
        '/lips_6_exercises': (context) => Lips6Exercises(),
        '/lips_7_exercises': (context) => Lips7Exercises(),
        '/tongue_1_exercises': (context) => Tongue1Exercises(),
        '/tongue_2_exercises': (context) => Tongue2Exercises(),
        '/tongue_3_exercises': (context) => Tongue3Exercises(),
        '/tongue_4_exercises': (context) => Tongue4Exercises(),
        '/tongue_5_exercises': (context) => Tongue5Exercises(),
        '/tongue_6_exercises': (context) => Tongue6Exercises(),
        '/tongue_7_exercises': (context) => Tongue7Exercises(),
      },
    );
  }
}
