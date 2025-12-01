import 'package:flutter/material.dart';
import 'package:untitled2/widget/streak_card.dart';
import 'package:untitled2/widget/task_card_initial.dart';
import 'package:untitled2/widget/task_card_modal.dart';
import 'package:untitled2/widget/task_card_tasks.dart';
import 'package:untitled2/widget/tabbar.dart';
// Импорт блока ежедневного подарка
import 'package:untitled2/widget/daily_gift_block.dart';

enum TaskCardState { initial, modal, tasks }

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedTabIndex = 0;
  final List<String> routes = [
    '/home',
    '/exercise_sections',
    '/photo_diary',
    '/profile_first',
  ];

  List<int> iconStates01 = [1, 0, 0, 0];
  TaskCardState cardState = TaskCardState.initial;
  List<String> tasks = ['Упражнение #1', 'Упражнение #2', 'Упражнение #3'];

  void _onTabSelected(int index) {
    setState(() {
      selectedTabIndex = index;
    });

    if (ModalRoute.of(context)?.settings.name != routes[index]) {
      Navigator.of(context).pushNamed(routes[index]);
    }
  }

  void _openCreateTaskModal() {
    setState(() {
      cardState = TaskCardState.modal;
    });
  }

  void _addTask(String text) {
    setState(() {
      if (text.trim().isNotEmpty) {
        tasks.add(text.trim());
        cardState = TaskCardState.tasks;
      }
    });
  }

  void _closeTaskModal() {
    setState(() {
      cardState = TaskCardState.initial;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double screenW = constraints.maxWidth;
          const double baseW = 375.0;
          final double scale = (screenW / baseW).clamp(0.85, 1.25);

          Widget baseTaskCardWidget;
          if (cardState == TaskCardState.tasks) {
            baseTaskCardWidget = TaskCardTasks(tasks: tasks);
          } else {
            baseTaskCardWidget =
                TaskCardInitial(onCreateTask: _openCreateTaskModal);
          }

          final double cardH = 236 * scale;
          Widget cardWrapper(Widget child) => Container(
            height: cardH,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24 * scale),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: child,
          );

          final listChildren = <Widget>[
            cardWrapper(const StreakCard()),
            const SizedBox(width: 8),
            cardWrapper(baseTaskCardWidget),
          ];

          final cardsBlock = Padding(
            padding: EdgeInsets.only(top: 12 * scale),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: cardH,
                  width: screenW,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none, // Не обрезать тени!
                    padding: EdgeInsets.symmetric(horizontal: 16.0 * scale),
                    physics: const BouncingScrollPhysics(),
                    children: listChildren,
                  ),
                ),
                SizedBox(height: 8 * scale), // 8 px от низа карточек до надписи
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0 * scale),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Свайпни вправо чтобы увидеть еще задачи',
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          height: 1.0,
                          letterSpacing: 0,
                          color: Color(0xFF777777),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Image.asset(
                        "assets/newimage/arrow.png",
                        width: 12,
                        height: 14,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );

          return Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    cardsBlock,
                    SizedBox(height: 8 * scale),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0 * scale),
                      child: const DailyGiftBlock(),
                    ),
                    const Expanded(child: SizedBox()),
                  ],
                ),
              ),
              if (cardState == TaskCardState.modal)
                Positioned.fill(
                  child: TaskCardModal(
                    onAddTask: (text) {
                      _addTask(text);
                    },
                    onClose: _closeTaskModal,
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: AbsorbPointer(
        absorbing: cardState == TaskCardState.modal,
        child: MainTabBar(
          iconStates01: iconStates01,
          selectedIndex: selectedTabIndex,
          onTabSelected: _onTabSelected,
        ),
      ),
    );
  }
}
