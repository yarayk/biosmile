import 'package:flutter/material.dart';

class HallOfFamePage extends StatelessWidget {
  const HallOfFamePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/image/fon7.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Header Image ("Зал славы")
                Image.asset(
                  'assets/image/zal_slavi.png',
                  width: 300,
                ),
                const SizedBox(height: 30),
                // First row of achievements
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      AchievementCard(
                        title: 'Новичок',
                        imagePath: 'assets/image/novice.png',
                      ),
                      AchievementCard(
                        title: 'Фотограф',
                        imagePath: 'assets/image/photographer.png',
                      ),
                      AchievementCard(
                        title: 'Серийный\nчемпион',
                        imagePath: 'assets/image/champion_gray.png',
                        multiline: true,
                        overlay: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                // Second row of achievements
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      AchievementCard(
                        title: 'Жжёшь!',
                        imagePath: 'assets/image/flame_gray.png',
                        overlay: true,
                      ),
                      AchievementCard(
                        title: 'Мастер',
                        imagePath: 'assets/image/master_gray.png',
                        overlay: true,
                      ),
                      AchievementCard(
                        title: 'Повелитель\nзверей',
                        imagePath: 'assets/image/zoo_gray.png',
                        multiline: true,
                        overlay: true,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Colors.amber, width: 3),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                      child: const Text(
                        'ВЫЙТИ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AchievementCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final bool multiline;
  final bool overlay;

  const AchievementCard({
    Key? key,
    required this.title,
    required this.imagePath,
    this.multiline = false,
    this.overlay = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                height: 90,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.amber, width: 3),
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(10),
                child: Center(child: Image.asset(imagePath)),
              ),
              if (overlay)
                Container(
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF5E2B),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
