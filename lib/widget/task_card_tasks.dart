import 'package:flutter/material.dart';

class TaskCardTasks extends StatefulWidget {
  final List<String> tasks;

  const TaskCardTasks({
    Key? key,
    required this.tasks,
  }) : super(key: key);

  @override
  State<TaskCardTasks> createState() => _TaskCardTasksState();
}

class _TaskCardTasksState extends State<TaskCardTasks> {
  bool remind = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 188,
      height: 236,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xffF9F9F9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8.97,
            offset: const Offset(0, 3.66),
          )
        ],
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок и дата
          const Text(
            'НАДО СДЕЛАТЬ',
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: Color(0xff81C784),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Пн, 7 Января',
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Color(0xff191919),
            ),
          ),
          const SizedBox(height: 8),

          // Скроллируемый список задач
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: widget.tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 5),
              itemBuilder: (context, index) => Text(
                widget.tasks[index],
                style: const TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: Color(0xff777777),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Кнопка "Напомнить мне"/"Не напоминать"
          GestureDetector(
            onTap: () => setState(() => remind = !remind),
            child: Container(
              width: 140,
              height: 36,
              decoration: BoxDecoration(
                color: remind ? const Color(0xff81C784) : const Color(0xffF2F2F2),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    remind
                        ? 'assets/newimage/bell_on.png'
                        : 'assets/newimage/bell_off.png',
                    width: 16,
                    height: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    remind ? 'Не напоминать' : 'Напомнить мне',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: remind ? Colors.white : const Color(0xff777777),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
