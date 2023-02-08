import 'package:flame_studio/src/core/settings.dart';
import 'package:flame_studio/src/widgets/flame_studio.dart';
import 'package:flutter/widgets.dart';

class Toolbar extends StatelessWidget {
  const Toolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Settings.of(context);
    final height = settings.toolbarHeight;
    final gap = height * 0.10;

    Widget _wrapButton(Widget button) {
      return Padding(padding: EdgeInsets.all(gap), child: button);
    }

    return Container(
      constraints: BoxConstraints.tightFor(height: height),
      decoration: BoxDecoration(
        boxShadow: const [
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
        color: settings.toolbarColor,
      ),
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(gap * 2, gap, gap * 10, gap * 2),
            child: Image.asset('logo_flame.png', fit: BoxFit.scaleDown),
          ),
          for (final button in FlameStudio.toolbarLeft) _wrapButton(button),
          Expanded(child: Container()),
          for (final button in FlameStudio.toolbarMiddle) _wrapButton(button),
          Expanded(child: Container()),
          for (final button in FlameStudio.toolbarRight) _wrapButton(button),
        ],
      ),
    );
  }
}
