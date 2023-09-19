import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/text.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class HardwareKeyboardExample extends FlameGame {
  static const String description = '''
    This example uses the HardwareKeyboardDetector mixin in order to keep
    track of which keys on a keyboard are currently pressed.

    Tap as many keys on the keyboard at once as you want, and see whether the
    system can detect them or not.
  ''';

  /// The list of [KeyboardKey] components currently shown on the screen. This
  /// list is re-generated on every RawKeyEvent. These components are also
  /// attached as children.
  List<KeyboardKey> _keyComponents = [];

  void replaceKeyComponents(List<KeyboardKey> newComponents) {
    for (final key in _keyComponents) {
      key.visible = false;
      key.removeFromParent();
    }
    _keyComponents = newComponents;
    addAll(_keyComponents);
  }

  @override
  void onLoad() {
    add(MyKeyboardDetector());
    add(
      TextComponent(
        text: 'Press any key(s)',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 12,
            color: Color(0x77ffffff),
          ),
        ),
      )..position = Vector2(80, 60),
    );
  }
}

class MyKeyboardDetector extends HardwareKeyboardDetector
    with HasGameReference<HardwareKeyboardExample> {
  @override
  void onKeyEvent(KeyEvent event) {
    final newComponents = <KeyboardKey>[];
    var x0 = 80.0;
    const y0 = 100.0;
    for (final key in physicalKeysPressed) {
      final keyComponent = KeyboardKey(
        text: keyNames[key] ?? '[${key.usbHidUsage} ${key.debugName}]',
        position: Vector2(x0, y0),
      );
      newComponents.add(keyComponent);
      x0 += keyComponent.width + 10;
    }
    game.replaceKeyComponents(newComponents);
  }

  /// The names of keyboard keys (at least the most important ones). We can't
  /// rely on `key.debugName` because this property is not available in release
  /// builds.
  static final Map<PhysicalKeyboardKey, String> keyNames = {
    PhysicalKeyboardKey.hyper: 'Hyper',
    PhysicalKeyboardKey.superKey: 'Super',
    PhysicalKeyboardKey.fn: 'Fn',
    PhysicalKeyboardKey.fnLock: 'FnLock',
    PhysicalKeyboardKey.gameButton1: 'Game 1',
    PhysicalKeyboardKey.gameButton2: 'Game 2 ',
    PhysicalKeyboardKey.gameButton3: 'Game 3',
    PhysicalKeyboardKey.gameButton4: 'Game 4',
    PhysicalKeyboardKey.gameButton5: 'Game 5',
    PhysicalKeyboardKey.gameButton6: 'Game 6',
    PhysicalKeyboardKey.gameButton7: 'Game 7',
    PhysicalKeyboardKey.gameButton8: 'Game 8',
    PhysicalKeyboardKey.gameButtonA: 'Game A',
    PhysicalKeyboardKey.gameButtonB: 'Game B',
    PhysicalKeyboardKey.gameButtonC: 'Game C',
    PhysicalKeyboardKey.gameButtonLeft1: 'Game L1',
    PhysicalKeyboardKey.gameButtonLeft2: 'Game L2',
    PhysicalKeyboardKey.gameButtonMode: 'Game Mode',
    PhysicalKeyboardKey.gameButtonRight1: 'Game R1',
    PhysicalKeyboardKey.gameButtonRight2: 'Game R2',
    PhysicalKeyboardKey.gameButtonSelect: 'Game Select',
    PhysicalKeyboardKey.gameButtonStart: 'Game Start',
    PhysicalKeyboardKey.gameButtonThumbLeft: 'Game LThumb',
    PhysicalKeyboardKey.gameButtonThumbRight: 'Game RThumb',
    PhysicalKeyboardKey.gameButtonX: 'Game X',
    PhysicalKeyboardKey.gameButtonY: 'Game Y',
    PhysicalKeyboardKey.gameButtonZ: 'Game Z',
    PhysicalKeyboardKey.keyA: 'A',
    PhysicalKeyboardKey.keyB: 'B',
    PhysicalKeyboardKey.keyC: 'C',
    PhysicalKeyboardKey.keyD: 'D',
    PhysicalKeyboardKey.keyE: 'E',
    PhysicalKeyboardKey.keyF: 'F',
    PhysicalKeyboardKey.keyG: 'G',
    PhysicalKeyboardKey.keyH: 'H',
    PhysicalKeyboardKey.keyI: 'I',
    PhysicalKeyboardKey.keyJ: 'J',
    PhysicalKeyboardKey.keyK: 'K',
    PhysicalKeyboardKey.keyL: 'L',
    PhysicalKeyboardKey.keyM: 'M',
    PhysicalKeyboardKey.keyN: 'N',
    PhysicalKeyboardKey.keyO: 'O',
    PhysicalKeyboardKey.keyP: 'P',
    PhysicalKeyboardKey.keyQ: 'Q',
    PhysicalKeyboardKey.keyR: 'R',
    PhysicalKeyboardKey.keyS: 'S',
    PhysicalKeyboardKey.keyT: 'T',
    PhysicalKeyboardKey.keyU: 'U',
    PhysicalKeyboardKey.keyV: 'V',
    PhysicalKeyboardKey.keyW: 'W',
    PhysicalKeyboardKey.keyX: 'X',
    PhysicalKeyboardKey.keyY: 'Y',
    PhysicalKeyboardKey.keyZ: 'Z',
    PhysicalKeyboardKey.digit1: '1',
    PhysicalKeyboardKey.digit2: '2',
    PhysicalKeyboardKey.digit3: '3',
    PhysicalKeyboardKey.digit4: '4',
    PhysicalKeyboardKey.digit5: '5',
    PhysicalKeyboardKey.digit6: '6',
    PhysicalKeyboardKey.digit7: '7',
    PhysicalKeyboardKey.digit8: '8',
    PhysicalKeyboardKey.digit9: '9',
    PhysicalKeyboardKey.digit0: '0',
    PhysicalKeyboardKey.enter: 'Enter',
    PhysicalKeyboardKey.escape: 'Esc',
    PhysicalKeyboardKey.backspace: 'Backspace',
    PhysicalKeyboardKey.tab: 'Tab',
    PhysicalKeyboardKey.space: 'Space',
    PhysicalKeyboardKey.minus: '-',
    PhysicalKeyboardKey.equal: '=',
    PhysicalKeyboardKey.bracketLeft: '[',
    PhysicalKeyboardKey.bracketRight: ']',
    PhysicalKeyboardKey.backslash: r'\',
    PhysicalKeyboardKey.semicolon: ';',
    PhysicalKeyboardKey.quote: "'",
    PhysicalKeyboardKey.backquote: '`',
    PhysicalKeyboardKey.comma: ',',
    PhysicalKeyboardKey.period: '.',
    PhysicalKeyboardKey.slash: '/',
    PhysicalKeyboardKey.capsLock: 'CapsLock',
    PhysicalKeyboardKey.f1: 'F1',
    PhysicalKeyboardKey.f2: 'F2',
    PhysicalKeyboardKey.f3: 'F3',
    PhysicalKeyboardKey.f4: 'F4',
    PhysicalKeyboardKey.f5: 'F5',
    PhysicalKeyboardKey.f6: 'F6',
    PhysicalKeyboardKey.f7: 'F7',
    PhysicalKeyboardKey.f8: 'F8',
    PhysicalKeyboardKey.f9: 'F9',
    PhysicalKeyboardKey.f10: 'F10',
    PhysicalKeyboardKey.f11: 'F11',
    PhysicalKeyboardKey.f12: 'F12',
    PhysicalKeyboardKey.f13: 'F13',
    PhysicalKeyboardKey.f14: 'F14',
    PhysicalKeyboardKey.f15: 'F15',
    PhysicalKeyboardKey.f16: 'F16',
    PhysicalKeyboardKey.printScreen: 'PrintScreen',
    PhysicalKeyboardKey.scrollLock: 'ScrollLock',
    PhysicalKeyboardKey.pause: 'Pause',
    PhysicalKeyboardKey.insert: 'Insert',
    PhysicalKeyboardKey.home: 'Home',
    PhysicalKeyboardKey.pageUp: 'PageUp',
    PhysicalKeyboardKey.delete: 'Delete',
    PhysicalKeyboardKey.end: 'End',
    PhysicalKeyboardKey.pageDown: 'PageDown',
    PhysicalKeyboardKey.arrowRight: 'ArrowRight',
    PhysicalKeyboardKey.arrowLeft: 'ArrowLeft',
    PhysicalKeyboardKey.arrowDown: 'ArrowDown',
    PhysicalKeyboardKey.arrowUp: 'ArrowUp',
    PhysicalKeyboardKey.numLock: 'NumLock',
    PhysicalKeyboardKey.numpadDivide: 'Num /',
    PhysicalKeyboardKey.numpadMultiply: 'Num *',
    PhysicalKeyboardKey.numpadSubtract: 'Num -',
    PhysicalKeyboardKey.numpadAdd: 'Num +',
    PhysicalKeyboardKey.numpadEnter: 'Num Enter',
    PhysicalKeyboardKey.numpad1: 'Num 1',
    PhysicalKeyboardKey.numpad2: 'Num 2',
    PhysicalKeyboardKey.numpad3: 'Num 3',
    PhysicalKeyboardKey.numpad4: 'Num 4',
    PhysicalKeyboardKey.numpad5: 'Num 5',
    PhysicalKeyboardKey.numpad6: 'Num 6',
    PhysicalKeyboardKey.numpad7: 'Num 7',
    PhysicalKeyboardKey.numpad8: 'Num 8',
    PhysicalKeyboardKey.numpad9: 'Num 9',
    PhysicalKeyboardKey.numpad0: 'Num 0',
    PhysicalKeyboardKey.numpadDecimal: 'Num .',
    PhysicalKeyboardKey.contextMenu: 'ContextMenu',
    PhysicalKeyboardKey.controlLeft: 'LControl',
    PhysicalKeyboardKey.shiftLeft: 'LShift',
    PhysicalKeyboardKey.altLeft: 'LAlt',
    PhysicalKeyboardKey.metaLeft: 'LMeta',
    PhysicalKeyboardKey.controlRight: 'RControl',
    PhysicalKeyboardKey.shiftRight: 'RShift',
    PhysicalKeyboardKey.altRight: 'RAlt',
    PhysicalKeyboardKey.metaRight: 'RMeta',
  };
}

class KeyboardKey extends PositionComponent {
  KeyboardKey({required this.text, super.position}) {
    textElement = textRenderer.format(text);
    width = textElement.metrics.width + padding.x;
    height = textElement.metrics.height + padding.y;
    textElement.translate(
      padding.x / 2,
      padding.y / 2 + textElement.metrics.ascent,
    );
    rect = RRect.fromLTRBR(0, 0, width, height, const Radius.circular(8));
  }

  final String text;
  late final InlineTextElement textElement;
  late final RRect rect;

  /// The RawKeyEvents may occur very fast, and out of sync with the game loop.
  /// On each such event we remove old KeyboardKey components, and add new ones.
  /// However, since multiple RawKeyEvents may occur within a single game tick,
  /// we end up adding/removing components many times within that tick, and for
  /// a brief moment there could be a situation that the old components still
  /// haven't been removed while the new ones were already added. In order to
  /// prevent this from happening, we mark all components that are about to be
  /// removed as "not visible", which prevents them from being rendered while
  /// they are waiting to be removed.
  bool visible = true;

  static final Vector2 padding = Vector2(24, 12);
  static final Paint borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..color = const Color(0xffb5ffd0);
  static final TextPaint textRenderer = TextPaint(
    style: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Color(0xffb5ffd0),
    ),
  );

  @override
  void render(Canvas canvas) {
    if (visible) {
      canvas.drawRRect(rect, borderPaint);
      textElement.draw(canvas);
    }
  }
}
