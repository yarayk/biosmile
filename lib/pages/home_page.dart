import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:untitled2/widget/streak_card.dart';
import 'package:untitled2/widget/task_card_initial.dart';
import 'package:untitled2/widget/task_card_modal.dart';
import 'package:untitled2/widget/task_card_tasks.dart';
import 'package:untitled2/widget/tabbar.dart';
import 'package:untitled2/widget/daily_gift_block.dart';
import 'package:untitled2/widget/last_task_card.dart';

enum TaskCardState { initial, modal, tasks }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // === SharedPreferences keys ===
  static const String _kLastSectionTitle = 'last_section_title';
  static const String _kLastSectionRoute = 'last_section_route';

  static const String _kLastExerciseNumber = 'last_exercise_number';
  static const String _kLastExerciseRoute = 'last_exercise_route';

  int selectedTabIndex = 0;
  final List<String> routes = const [
    '/home',
    '/exercise_sections',
    '/photo_diary',
    '/profile_first',
  ];

  List<int> iconStates01 = [1, 0, 0, 0];

  TaskCardState cardState = TaskCardState.initial;
  List<String> tasks = ['Упражнение #1', 'Упражнение #2', 'Упражнение #3'];

  bool streakCompact = false;

  // === То, что будет отображаться на карточке (по умолчанию как раньше) ===
  String lastCardTitle = 'Упражнение №1';
  String lastCardSubtitle = 'Упражнения для мимики';

  // === Route для кнопки "Продолжить?" (конкретное упражнение) ===
  String? lastExerciseRoute;

  // === Route последнего раздела (для выбора острова) ===
  String? lastSectionRoute;

  @override
  void initState() {
    super.initState();
    _loadLastTask();
  }

  Future<void> _loadLastTask() async {
    final prefs = await SharedPreferences.getInstance();

    final int? exNum = prefs.getInt(_kLastExerciseNumber);
    final String? sectionTitle = prefs.getString(_kLastSectionTitle);
    final String? exRoute = prefs.getString(_kLastExerciseRoute);
    final String? sectionRoute = prefs.getString(_kLastSectionRoute);

    if (!mounted) return;

    // Если данных ещё нет — ничего не меняем (останется как раньше).
    if (exNum == null || (sectionTitle == null || sectionTitle.trim().isEmpty)) {
      setState(() {
        lastExerciseRoute = exRoute; // может быть null
        lastSectionRoute = sectionRoute; // может быть null
      });
      return;
    }

    setState(() {
      lastCardTitle = 'Упражнение №$exNum';
      lastCardSubtitle = sectionTitle.trim();
      lastExerciseRoute = exRoute;
      lastSectionRoute = sectionRoute;
    });
  }

  void _onTabSelected(int index) {
    setState(() => selectedTabIndex = index);

    if (ModalRoute.of(context)?.settings.name != routes[index]) {
      Navigator.of(context).pushNamed(routes[index]);
    }
  }

  void _openCreateTaskModal() {
    setState(() => cardState = TaskCardState.modal);
  }

  void _addTask(String text) {
    setState(() {
      final t = text.trim();
      if (t.isNotEmpty) {
        tasks.add(t);
        cardState = TaskCardState.tasks;
      }
    });
  }

  void _closeTaskModal() {
    setState(() => cardState = TaskCardState.initial);
  }

  void _handleTopSwipe(DragEndDetails details) {
    if (cardState == TaskCardState.modal) return;

    final v = details.primaryVelocity;
    if (v == null) return;

    const double threshold = 250;

    if (v > threshold) {
      setState(() => streakCompact = false);
    } else if (v < -threshold) {
      setState(() => streakCompact = true);
    }
  }

  void _onContinueLastTask() {
    final route = (lastExerciseRoute ?? '').trim();

    if (route.isNotEmpty) {
      Navigator.of(context).pushNamed(route);
    } else {
      // Если route ещё не сохранён — просто ведём в разделы упражнений
      Navigator.of(context).pushNamed('/exercise_sections');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double screenW = constraints.maxWidth;
          const double baseW = 375.0;
          final double scale = (screenW / baseW).clamp(0.85, 1.25);

          final double cardH = 237.0 * scale;

          final double streakExpandedW = 178.0 * scale;
          final double streakCompactW = 74.0 * scale;
          final double taskCardW = 178.0 * scale;

          final double paddingH = 16.0 * scale;
          final double spacing = 8.0 * scale;

          final double streakW = streakCompact ? streakCompactW : streakExpandedW;
          final double taskLeft = paddingH + streakW + spacing;

          Widget baseTaskCardWidget;
          if (cardState == TaskCardState.tasks) {
            baseTaskCardWidget = TaskCardTasks(tasks: tasks);
          } else {
            baseTaskCardWidget = TaskCardInitial(onCreateTask: _openCreateTaskModal);
          }

          Widget cardWrapper({
            required double width,
            required Widget child,
          }) {
            return Container(
              width: width,
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
          }

          final cardsBlock = GestureDetector(
            onHorizontalDragEnd: _handleTopSwipe,
            child: Padding(
              padding: EdgeInsets.only(top: 12 * scale),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: cardH,
                    width: screenW,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: paddingH,
                          top: 0,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                            width: streakW,
                            height: cardH,
                            child: StreakCard(
                              width: streakW,
                              height: cardH,
                              view: streakCompact
                                  ? StreakCardView.compact
                                  : StreakCardView.expanded,
                            ),
                          ),
                        ),
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                          left: taskLeft,
                          top: 0,
                          child: cardWrapper(
                            width: taskCardW,
                            child: baseTaskCardWidget,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8 * scale),
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
            ),
          );

          return Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  physics: cardState == TaskCardState.modal
                      ? const NeverScrollableScrollPhysics()
                      : const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: kBottomNavigationBarHeight + bottomInset + 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        cardsBlock,
                        SizedBox(height: 8 * scale),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0 * scale),
                          child: const DailyGiftBlock(),
                        ),
                        SizedBox(height: 16 * scale),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0 * scale),
                          child: LastTaskCard(
                            title: lastCardTitle,
                            subtitle: lastCardSubtitle,
                            sectionRoute: lastSectionRoute,
                            onContinue: _onContinueLastTask,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (cardState == TaskCardState.modal)
                Positioned.fill(
                  child: TaskCardModal(
                    onAddTask: (text) => _addTask(text),
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
