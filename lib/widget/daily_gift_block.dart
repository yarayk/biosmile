import 'package:flutter/material.dart';

class GiftDayItem {
  final String assetName;
  final String state;
  final String label;

  GiftDayItem({
    required this.assetName,
    required this.state,
    required this.label,
  });
}

class DailyGiftBlock extends StatefulWidget {
  const DailyGiftBlock({super.key});

  @override
  State<DailyGiftBlock> createState() => _DailyGiftBlockState();
}

class _DailyGiftBlockState extends State<DailyGiftBlock> {
  int achievementState = 2;
  String achievementTitle = 'На шаг ближе к цели';
  String achievementSubtitle = 'Выполни своё первое упражнение';

  final String achImageGray = 'assets/newimage/reward_gray.png';
  final String achImageBright = 'assets/newimage/reward_bright.png';
  final String achImageNextGray = 'assets/newimage/day7.png';
  final String coinIcon20 = 'assets/newimage/coin_20.png';

  final int rewardCoins = 200;
  int progressCurrent = 0;
  int progressTotal = 1;

  List<GiftDayItem> items = [
    GiftDayItem(assetName: 'assets/newimage/gift01.png', state: 'claimed', label: 'Получено'),
    GiftDayItem(assetName: 'assets/newimage/gift01.png', state: 'claimed', label: 'Получено'),
    GiftDayItem(assetName: 'assets/newimage/gift_stack.png', state: 'claim', label: 'Забрать'),
    GiftDayItem(assetName: 'assets/newimage/hat.png', state: 'claim', label: 'Забрать'),
    GiftDayItem(assetName: 'assets/newimage/gift01.png', state: 'waiting', label: 'День 5'),
    GiftDayItem(assetName: 'assets/newimage/gift_stack.png', state: 'waiting', label: 'День 6'),
    GiftDayItem(assetName: 'assets/newimage/day7.png', state: 'waiting', label: 'День 7'),
  ];

  void _claim(int index) {
    setState(() {
      items[index] = GiftDayItem(
        assetName: items[index].assetName,
        state: 'claimed',
        label: 'Получено',
      );
    });
  }

  void _onTapClaimReward() {
    setState(() {
      achievementState = 1;
      achievementTitle = 'На шаг ближе к цели';
      achievementSubtitle = 'Выполни 7 заходов';
      progressCurrent = 0;
      progressTotal = 7;
    });
  }

  Widget _claimLabel(String text, double scale, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 20 * scale,
        width: 56 * scale,
        decoration: BoxDecoration(
          color: const Color(0xFF81C784),
          borderRadius: BorderRadius.circular(2112),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w400,
            fontSize: 12 * scale,
            height: 14 / 12,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _waitingLabel(String text, double scale) {
    return Container(
      height: 20 * scale,
      width: 56 * scale,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2112),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w400,
          fontSize: 12 * scale,
          height: 1.0,
          color: const Color(0xFF81C784),
        ),
      ),
    );
  }

  Widget _claimedLabel(String text, double scale) {
    return Container(
      height: 20 * scale,
      width: 56 * scale,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2112),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w400,
          fontSize: 12 * scale,
          color: const Color(0xFF81C784),
        ),
      ),
    );
  }

  Widget _progressBar({
    required double scale,
    required int current,
    required int total,
  }) {
    final double width = 219 * scale;
    final double height = 23 * scale;
    final double ratio = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;
    final double fillWidth = width * ratio;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(2112),
      ),
      alignment: Alignment.centerLeft,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: fillWidth,
            height: height,
            decoration: BoxDecoration(
              color: const Color(0xFF81C784),
              borderRadius: BorderRadius.circular(56),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Text(
                '$current/$total',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w400,
                  fontSize: 14 * scale,
                  height: 17 / 14,
                  color: const Color(0xFF777777),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _claimRewardButton(double scale) {
    return GestureDetector(
      onTap: _onTapClaimReward,
      child: Container(
        width: 219 * scale,
        height: 23 * scale,
        decoration: BoxDecoration(
          color: const Color(0xFF81C784),
          borderRadius: BorderRadius.circular(56),
        ),
        alignment: Alignment.center,
        child: Text(
          'Забрать награду',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w400,
            fontSize: 14 * scale,
            height: 17 / 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _rewardChip(double scale) {
    return Container(
      height: 20 * scale,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(2112),
      ),
      padding: EdgeInsets.symmetric(horizontal: 5 * scale),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            coinIcon20,
            width: 20 * scale,
            height: 20 * scale,
            fit: BoxFit.cover,
          ),
          SizedBox(width: 4 * scale),
          Text(
            '+$rewardCoins',
            style: TextStyle(
              fontFamily: 'SF Pro Display',
              fontWeight: FontWeight.w400,
              fontSize: 14 * scale,
              height: 17 / 14,
              color: const Color(0xFF81C784),
            ),
          ),
        ],
      ),
    );
  }

  Widget _achievementBlock(double scale) {
    if (achievementState == 0) return const SizedBox.shrink();

    final String leftImage = achievementState == 2 ? achImageBright : achImageGray;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 88 * scale,
          height: 98 * scale,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16 * scale),
            child: Image.asset(leftImage, fit: BoxFit.cover),
          ),
        ),
        SizedBox(width: 16 * scale),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      achievementTitle,
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w500,
                        fontSize: 14 * scale,
                        height: 17 / 14,
                        color: const Color(0xFF191919),
                      ),
                    ),
                  ),
                  SizedBox(width: 8 * scale),
                  _rewardChip(scale),
                ],
              ),
              SizedBox(height: 4 * scale),
              Text(
                achievementSubtitle,
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w400,
                  fontSize: 12 * scale,
                  height: 14 / 12,
                  color: const Color(0xFF777777),
                ),
              ),
              SizedBox(height: 8 * scale),
              if (achievementState == 2)
                _claimRewardButton(scale)
              else
                _progressBar(
                  scale: scale,
                  current: progressCurrent,
                  total: progressTotal,
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double baseW = 375.0;
        final double screenW = constraints.maxWidth;
        final double scale = (screenW / baseW).clamp(0.85, 1.25);

        final double itemIcon = 52 * scale;
        final double itemGap = 8 * scale;
        final double itemBar = 20 * scale;
        final double rowHeight = itemIcon + itemGap + itemBar;
        final double achHeight = (achievementState == 0) ? 0 : (98 * scale);
        final double totalHeight = achHeight + ((achievementState == 0) ? 0 : (8 * scale)) + rowHeight + 16 + 16;

        return ClipRRect(
          borderRadius: BorderRadius.circular(26 * scale),
          clipBehavior: Clip.antiAlias,
          child: Container(
            height: totalHeight,
            padding: const EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            color: Colors.white,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (achievementState != 0) _achievementBlock(scale),
                  if (achievementState != 0) SizedBox(height: 8 * scale),
                  SizedBox(
                    height: rowHeight,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.hardEdge,
                      padding: EdgeInsets.symmetric(horizontal: 16.0 * scale),
                      separatorBuilder: (context, i) => SizedBox(width: 12 * scale),
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final item = items[i];
                        return SizedBox(
                          width: 65 * scale,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // УБРАНО скругление: больше нет ClipOval
                              SizedBox(
                                width: 52 * scale,
                                height: 52 * scale,
                                child: Image.asset(
                                  item.assetName,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(height: 8 * scale),
                              if (item.state == 'waiting')
                                _waitingLabel(item.label, scale)
                              else if (item.state == 'claim')
                                _claimLabel(
                                  item.label,
                                  scale,
                                      () => _claim(i),
                                )
                              else
                                _claimedLabel(item.label, scale),
                            ],
                          ),
                        );
                      },
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
