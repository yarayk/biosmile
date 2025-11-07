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
        color: Color(0xffF9F9F9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8.97,
            offset: Offset(0, 3.66),
          )
        ],
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок, дата, задачи
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'НАДО СДЕЛАТЬ',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: Color(0xff81C784),
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Пн, 7 Января',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Color(0xff191919),
                ),
              ),
              SizedBox(height: 8),
              ...widget.tasks.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  t,
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Color(0xff777777),
                  ),
                ),
              )),
            ],
          ),
          // Кнопка "Напомнить мне"/"Не напоминать"
          GestureDetector(
            onTap: () => setState(() => remind = !remind),
            child: Container(
              margin: EdgeInsets.only(top: 8),
              width: 140,
              height: 36,
              decoration: BoxDecoration(
                color: remind ? Color(0xff81C784) : Color(0xffF2F2F2),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Колокольчик PNG
                  Image.asset(
                    remind ? 'assets/newimage/bell_on.png' : 'assets/newimage/bell_off.png', // твои PNG 16x16
                    width: 16,
                    height: 16,
                  ),
                  SizedBox(width: 8),
                  Text(
                    remind ? 'Не напоминать' : 'Напомнить мне',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: remind ? Colors.white : Color(0xff777777),
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
