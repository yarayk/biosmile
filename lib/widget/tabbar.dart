import 'package:flutter/material.dart';

/// Кастомный нижний таббар.
/// Теперь поддерживает бинарные состояния иконок через [iconStates01]:
/// - 0 = серая иконка/текст
/// - 1 = зелёная иконка/текст
/// Если [iconStates01] не передан или длина не совпадает с количеством табов,
/// используется стандартная логика: активен только [selectedIndex].
class MainTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  /// Необязательный список бинарных состояний иконок.
  /// Длина должна совпадать с количеством табов.
  /// Значения только 0 или 1.
  final List<int>? iconStates01;

  const MainTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    this.iconStates01,
  });

  // Конфигурация табов и маршрутов
  final List<_TabItem> _tabs = const [
    _TabItem(
      title: 'Главная',
      icon: 'assets/newimage/home.png',
      iconActive: 'assets/newimage/home_green.png',
      route: '/home',
    ),
    _TabItem(
      title: 'Упражнения',
      icon: 'assets/newimage/exercise.png',
      iconActive: 'assets/newimage/exercise_green.png',
      route: '/exercise_sections',
    ),
    _TabItem(
      title: 'Фото-Дневник',
      icon: 'assets/newimage/diary.png',
      iconActive: 'assets/newimage/diary_green.png',
      route: '/photo_diary',
    ),
    _TabItem(
      title: 'Профиль',
      icon: 'assets/newimage/profile.png',
      iconActive: 'assets/newimage/profile_green.png',
      route: '/profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Отключаем системное масштабирование текста только для таббара.
    // TextScaler — актуальный способ управления масштабом текста.
    final mq = MediaQuery.of(context);
    final textScalerOff = mq.copyWith(textScaler: const TextScaler.linear(1.0));

    // Проверяем валидность принудительных состояний (длина и значения 0/1)
    bool _isValidForcedStates() {
      if (iconStates01 == null) return false;
      if (iconStates01!.length != _tabs.length) return false;
      for (final v in iconStates01!) {
        if (v != 0 && v != 1) return false;
      }
      return true;
    }

    final bool useForcedStates = _isValidForcedStates();

    return MediaQuery(
      data: textScalerOff,
      child: Material(
        color: const Color(0xFFFFFFFF),
        elevation: 0,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64, // типовая высота нижнего бара
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(_tabs.length, (index) {
                final tab = _tabs[index];

                // Если есть корректные принудительные состояния — используем их.
                // Иначе — активен только выбранный таб.
                final bool isGreen = useForcedStates
                    ? iconStates01![index] == 1
                    : selectedIndex == index;

                final Color color =
                isGreen ? const Color(0xFF81C784) : const Color(0xFFC9C9C9);

                return Expanded(
                  child: InkWell(
                    onTap: () => onTabSelected(index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Вывод нужной версии иконки из assets
                          Image.asset(
                            isGreen ? tab.iconActive : tab.icon,
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(height: 4),
                          // Подстраховка от длинных локализаций
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              tab.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'SF Pro',
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                                height: 1.2,
                                letterSpacing: -0.24,
                              ).copyWith(color: color),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final String title;
  final String icon;
  final String iconActive;
  final String route;
  const _TabItem({
    required this.title,
    required this.icon,
    required this.iconActive,
    required this.route,
  });
}
