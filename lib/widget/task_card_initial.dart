import 'package:flutter/material.dart';

class TaskCardInitial extends StatefulWidget {
  final VoidCallback onCreateTask;
  const TaskCardInitial({Key? key, required this.onCreateTask}) : super(key: key);

  @override
  State<TaskCardInitial> createState() => _TaskCardInitialState();
}

class _TaskCardInitialState extends State<TaskCardInitial> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 188,
      height: 236,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07), // как в CSS
              blurRadius: 8.97,
              offset: const Offset(0, 3.66),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              const Positioned(
                left: -13,
                top: 90,
                width: 198,
                height: 180.5,
                child: _FrogImage(),
              ),
              Positioned(
                top: 24,
                left: 0,
                right: 0,
                height: 52,
                child: Center(
                  child: GestureDetector(
                    onTap: widget.onCreateTask,
                    child: Container(
                      width: 156,
                      height: 52,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Создать задачу',
                            style: TextStyle(
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              height: 14 / 12,
                              color: Color(0xFF777777),
                            ),
                          ),
                          const SizedBox(width: 4),
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: Center(
                              child: Image.asset(
                                'assets/newimage/plus_icon.png',
                                width: 18,
                                height: 18,
                                color: const Color(0xFFC9C9C9),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FrogImage extends StatelessWidget {
  const _FrogImage();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/newimage/frog_image.png',
      fit: BoxFit.contain,
    );
  }
}
