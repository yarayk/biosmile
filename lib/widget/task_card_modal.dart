import 'dart:ui';
import 'package:flutter/material.dart';

class TaskCardModal extends StatefulWidget {
  final Function(String) onAddTask;
  final VoidCallback onClose;

  const TaskCardModal({
    Key? key,
    required this.onAddTask,
    required this.onClose,
  }) : super(key: key);

  @override
  State<TaskCardModal> createState() => _TaskCardModalState();
}

class _TaskCardModalState extends State<TaskCardModal> {
  final TextEditingController _controller = TextEditingController();
  bool get _canAdd => _controller.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Фон
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: Container(color: Colors.black.withOpacity(0.2)),
          ),
        ),
        // Модальное окно
        Center(
          child: Container(
            width: 343,
            height: 230, // ↑↑↑ тут увеличиваем высоту, чтобы ничего не перекрывалось
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Stack(
              children: [
                // Стрелка (PNG), опускайте ниже, увеличивая top:
                Positioned(
                  left: 8,
                  top: 14, // ← меняйте top для смещения стрелки вниз
                  child: GestureDetector(
                    onTap: widget.onClose,
                    child: Image.asset(
                      'assets/newimage/arrow_left.png',
                      width: 18,
                      height: 18,
                    ),
                  ),
                ),
                // Основное содержимое
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 10),
                    Center(
                      child: Text(
                        'Создать задачу',
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          height: 21 / 18,
                          color: Color(0xff191919),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Container(
                      width: 311,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Что нужно сделать?',
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          height: 1,
                          color: Color(0xff777777),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: 311,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Color(0xffF2F2F2),
                        borderRadius: BorderRadius.circular(101),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _controller,
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          height: 14 / 12,
                          color: Color(0xff191919),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Напишите здесь новую задачу',
                          hintStyle: TextStyle(
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            height: 14 / 12,
                            color: Color(0xff777777),
                          ),
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(311, 43),
                        backgroundColor: Color(0xff81C784),
                        disabledBackgroundColor: Color(0xff81C784),
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(69),
                        ),
                        textStyle: TextStyle(
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          height: 19 / 16,
                        ),
                      ),
                      onPressed: _canAdd
                          ? () => widget.onAddTask(_controller.text.trim())
                          : null,
                      child: Text(
                        'Добавить',
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          height: 19 / 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Увеличенный отступ снизу для аккуратности
                    SizedBox(height: 7), // ↑↑↑ регулируйте тут
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
