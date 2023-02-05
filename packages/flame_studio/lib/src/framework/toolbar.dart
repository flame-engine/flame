import 'package:flutter/widgets.dart';

class Toolbar extends StatelessWidget {
  const Toolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.tightFor(height: 25),
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
          )
        ],
        color: Color(0xff303030),
      ),
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 24, 4),
            child: Image.asset('logo_flame.png', fit: BoxFit.scaleDown),
          ),
        ],
      ),
    );
  }
}
