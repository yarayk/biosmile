import 'package:flutter/material.dart';

class GiftDayItem {
  final String assetName;
  final String state; // "claimed", "claim", "waiting"
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

  // Тень у кнопки "Забрать" теперь как у "День 5"
  Widget _claimLabel(String text, double scale, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 20 * scale, // соответствует height: 20px
        width: 56 * scale,  // соответствует width: 56px
        decoration: BoxDecoration(
          color: const Color(0xFF81C784), // background: #81C784
          borderRadius: BorderRadius.circular(2112), // border-radius: 2112px
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15), // box-shadow: rgba(0,0,0,0.15)
              offset: Offset(0, 2 * scale), // 0px 2px
              blurRadius: 12 * scale, // 12px
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'SF Pro Display', // font-family
            fontWeight: FontWeight.w400,  // font-weight: 400
            fontSize: 12 * scale,         // font-size: 12px
            height: 14 / 12,              // line-height: 14px => 14/12
            color: Colors.white,          // color: #FFFFFF
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            offset: Offset(0, 2 * scale),
            blurRadius: 12 * scale,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w400,
          fontSize: 12 * scale,
          height: 1.0,
          color: Color(0xFF81C784),
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
          color: Color(0xFF81C784),
        ),
      ),
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
        final double itemGap = 8;
        final double itemBar = 20 * scale;
        final double rowHeight = itemIcon + itemGap + itemBar;

        return Container(
          height: 210 * scale,
          padding: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26 * scale),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: rowHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
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
                        Container(
                          width: 52 * scale,
                          height: 52 * scale,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(1000),
                          ),
                          child: Image.asset(
                            item.assetName,
                            width: 52 * scale,
                            height: 52 * scale,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: itemGap),
                        if (item.state == 'waiting')
                          _waitingLabel(item.label, scale)
                        else if (item.state == 'claim')
                          _claimLabel(
                            item.label,
                            scale,
                                () => _claim(i),
                          )
                        else // claimed
                          _claimedLabel(
                            item.label,
                            scale,
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
