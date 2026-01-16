import 'package:flutter/material.dart';

class Cheeks5Exercises extends StatefulWidget {
  const Cheeks5Exercises({super.key});

  @override
  State<Cheeks5Exercises> createState() => _Cheeks5ExercisesState();
}

class _Cheeks5ExercisesState extends State<Cheeks5Exercises> {
  static const Color _bg = Color(0xFFF9F9F9);
  static const Color _green = Color(0xFF81C784);

  Widget _videoArea() {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Container(
        width: double.infinity,
        color: _bg,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Упражнение пока в разработке',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _green,
                ),
              ),
              const SizedBox(height: 16),
              Image.asset(
                'assets/newimage/frog1.png',
                width: 200,
                height: 262,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _backButton() {
    return SizedBox(
      width: 247,
      height: 37,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Вернуться назад',
          style: TextStyle(
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            height: 21 / 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Stack(
          children: [
            // Кнопка назад (иконка)
            Positioned(
              top: 8,
              left: 8,
              child: SizedBox(
                width: 34,
                height: 34,
                child: Material(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(
                      color: Color(0xFFF5F5F5),
                      width: 1,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => Navigator.pop(context),
                    child: Center(
                      child: Image.asset(
                        'assets/exercise/arrow_left.png',
                        width: 18,
                        height: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Контент
            Positioned.fill(
              top: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _videoArea(),
                  const SizedBox(height: 12),
                  Center(child: _backButton()),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

