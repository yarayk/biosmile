import 'package:flutter/material.dart';

class IslandOverlaySpec {
  final String asset;
  final double left;
  final double top;
  final double width;
  final double height;

  const IslandOverlaySpec({
    required this.asset,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
}

class LastTaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onContinue;

  /// Route последнего раздела (например: '/cheeks_exercises')
  final String? sectionRoute;

  /// Путь к иконке 20x20
  final String playIconAsset;

  const LastTaskCard({
    super.key,
    this.title = 'Упражнение №1',
    this.subtitle = 'Упражнения для мимики',
    this.onContinue,
    this.sectionRoute,
    this.playIconAsset = 'assets/newimage/play2.png',
  });

  // СТАРЫЕ размеры карточки (оставляем как было)
  static const _cardW = 343.0;
  static const _cardH = 210.0;

  // СТАРЫЕ параметры контента (оставляем как было)
  static const _contentLeft = 20.0;
  static const _contentTop = 20.0;
  static const _contentW = 252.0;
  static const _contentH = 119.0;

  static const _radiusCard = 28.0;
  static const _radiusButton = 32.0;

  static const _gapTitleSubtitle = 4.0;
  static const _gapBetweenBlocks = 32.0;

  static const _btnW = 190.0;
  static const _btnH = 37.0;

  // Figma: island координаты внутри Last Task (343.28 x 217)
  static const double _figmaCardW = 343.28;
  static const double _figmaCardH = 217.0;

  // Острова по route (твои CSS)
  static const Map<String, IslandOverlaySpec> _islandByRoute = {
    // мимика
    '/face_exercises': IslandOverlaySpec(
      asset: 'assets/exercise/island_face.png',
      left: 158,
      top: 53,
      width: 179,
      height: 158,
    ),
    // губы
    '/lips_exercises': IslandOverlaySpec(
      asset: 'assets/exercise/island_lips.png',
      left: 149,
      top: 32,
      width: 209,
      height: 213,
    ),
    // щеки
    '/cheeks_exercises': IslandOverlaySpec(
      asset: 'assets/exercise/island_cheeks.png',
      left: 150,
      top: 34,
      width: 207,
      height: 193,
    ),
    // челюсть
    '/jaw_exercises': IslandOverlaySpec(
      asset: 'assets/exercise/island_jaw.png',
      left: 158,
      top: 45,
      width: 194,
      height: 167,
    ),
    // язык
    '/tongue_exercises': IslandOverlaySpec(
      asset: 'assets/exercise/island_tongue.png',
      left: 146,
      top: 23,
      width: 197,
      height: 208,
    ),
    // дополнительно
    '/additional_exercises': IslandOverlaySpec(
      asset: 'assets/exercise/island_additional.png',
      left: 178,
      top: 35,
      width: 176,
      height: 172,
    ),
  };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Снаружи карточка у тебя фиксированная 343x210,
        // но если родитель даст другую ширину — остров масштабируем относительно ширины. [web:31]
        final double cardW = constraints.hasBoundedWidth && constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : _cardW;

        final double scale = (cardW / _figmaCardW).clamp(0.85, 1.25);

        final spec = _islandByRoute[(sectionRoute ?? '').trim()];

        return SizedBox(
          width: _cardW,
          height: _cardH,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(_radiusCard),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_radiusCard),
              child: Stack(
                children: [
                  // 1) ОСТРОВ — добавили только его, он в фоне (за всем контентом)
                  if (spec != null)
                    Positioned(
                      left: spec.left * scale,
                      top: spec.top * scale,
                      width: spec.width * scale,
                      height: spec.height * scale,
                      child: IgnorePointer(
                        child: Image.asset(
                          spec.asset,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),

                  // 2) ТВОЙ СТАРЫЙ КОНТЕНТ — без изменений
                  Positioned(
                    left: _contentLeft,
                    top: _contentTop,
                    child: SizedBox(
                      width: _contentW,
                      height: _contentH,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: _contentW,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'SF Pro',
                                    fontWeight: FontWeight.w600, // ~590
                                    fontSize: 24,
                                    height: 29 / 24,
                                    color: Color(0xFF191919),
                                  ),
                                ),
                                const SizedBox(height: _gapTitleSubtitle),
                                Text(
                                  subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'SF Pro',
                                    fontWeight: FontWeight.w500, // ~510
                                    fontSize: 14,
                                    height: 17 / 14,
                                    color: Color(0xFF777777),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: _gapBetweenBlocks),
                          Material(
                            color: const Color(0xFF81C784),
                            borderRadius: BorderRadius.circular(_radiusButton),
                            child: InkWell(
                              onTap: onContinue,
                              borderRadius: BorderRadius.circular(_radiusButton),
                              child: SizedBox(
                                width: _btnW,
                                height: _btnH,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            'Продолжить?',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontFamily: 'SF Pro',
                                              fontWeight: FontWeight.w600, // ~590
                                              fontSize: 18,
                                              height: 21 / 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: Image.asset(
                                          playIconAsset,
                                          width: 20,
                                          height: 20,
                                          fit: BoxFit.contain,
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
