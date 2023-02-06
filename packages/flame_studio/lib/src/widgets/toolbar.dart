import 'package:flame_studio/src/widgets/flame_studio_settings.dart';
import 'package:flutter/widgets.dart';

class Toolbar extends StatelessWidget {
  const Toolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = FlameStudioSettings.of(context);
    final height = settings.toolbarHeight;
    final gap = height * 0.20;

    return Container(
      constraints: BoxConstraints.tightFor(height: height),
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x66000000),
            offset: Offset(0, 3),
            blurRadius: 7.0,
          ),
          BoxShadow(
            color: Color(0xbf000000),
            offset: Offset(0, 1),
            blurRadius: 2.0,
          ),
        ],
        color: Color(0xff303030),
      ),
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(gap, gap / 2, height, gap),
            child: Image.asset('logo_flame.png', fit: BoxFit.scaleDown),
          ),
        ],
      ),
    );
  }
}
