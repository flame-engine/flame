import 'package:examples/commons/commons.dart';
import 'package:examples/commons/example_use_case.dart';
import 'package:examples/stories/input/advanced_button_example.dart';
import 'package:examples/stories/input/double_tap_callbacks_example.dart';
import 'package:examples/stories/input/drag_callbacks_example.dart';
import 'package:examples/stories/input/dynamic_scale_drag_example.dart';
import 'package:examples/stories/input/gesture_hitboxes_example.dart';
import 'package:examples/stories/input/hardware_keyboard_example.dart';
import 'package:examples/stories/input/hover_callbacks_example.dart';
import 'package:examples/stories/input/joystick_advanced_example.dart';
import 'package:examples/stories/input/joystick_example.dart';
import 'package:examples/stories/input/keyboard_example.dart';
import 'package:examples/stories/input/keyboard_listener_component_example.dart';
import 'package:examples/stories/input/long_press_example.dart';
import 'package:examples/stories/input/mouse_cursor_example.dart';
import 'package:examples/stories/input/mouse_movement_example.dart';
import 'package:examples/stories/input/multitap_advanced_example.dart';
import 'package:examples/stories/input/multitap_example.dart';
import 'package:examples/stories/input/overlapping_tap_callbacks_example.dart';
import 'package:examples/stories/input/scroll_example.dart';
import 'package:examples/stories/input/secondary_tap_callbacks_example.dart';
import 'package:examples/stories/input/tap_callbacks_example.dart';
import 'package:examples/stories/input/tertiary_tap_callbacks_example.dart';
import 'package:flame/game.dart';
import 'package:material_ui/material_ui.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookComponent inputStories() {
  return WidgetbookComponent(
    name: 'Input',
    useCases: [
      ExampleUseCase(
        name: 'TapCallbacks',
        builder: (_) => GameWidget(game: TapCallbacksExample()),
        codeLink: baseLink('input/tap_callbacks_example.dart'),
        info: TapCallbacksExample.description,
      ),
      ExampleUseCase(
        name: 'SecondaryTapCallbacks',
        builder: (_) => GameWidget(game: SecondaryTapCallbacksExample()),
        codeLink: baseLink('input/secondary_tap_callbacks_example.dart'),
        info: SecondaryTapCallbacksExample.description,
      ),
      ExampleUseCase(
        name: 'TertiaryTapCallbacks',
        builder: (_) => GameWidget(game: TertiaryTapCallbacksExample()),
        codeLink: baseLink('input/tertiary_tap_callbacks_example.dart'),
        info: TertiaryTapCallbacksExample.description,
      ),
      ExampleUseCase(
        name: 'DragCallbacks',
        builder: (context) {
          return GameWidget(
            game: DragCallbacksExample(
              zoom: context.knobs.object.dropdown(
                label: 'zoom',
                initialOption: 1,
                options: [0.5, 1, 1.5],
              ),
            ),
          );
        },
        codeLink: baseLink('input/drag_callbacks_example.dart'),
        info: DragCallbacksExample.description,
      ),
      ExampleUseCase(
        name: 'Double Tap (Component)',
        builder: (context) {
          return GameWidget(
            game: DoubleTapCallbacksExample(),
          );
        },
        codeLink: baseLink('input/double_tap_callbacks_example.dart'),
        info: DoubleTapCallbacksExample.description,
      ),
      ExampleUseCase(
        name: 'HoverCallbacks',
        builder: (_) => GameWidget(game: HoverCallbacksExample()),
        codeLink: baseLink('input/hover_callbacks_example.dart'),
        info: HoverCallbacksExample.description,
      ),
      ExampleUseCase(
        name: 'Keyboard',
        builder: (_) => GameWidget(game: KeyboardExample()),
        codeLink: baseLink('input/keyboard_example.dart'),
        info: KeyboardExample.description,
      ),
      ExampleUseCase(
        name: 'Keyboard (Component)',
        builder: (_) => GameWidget(game: KeyboardListenerComponentExample()),
        codeLink: baseLink('input/keyboard_listener_component_example.dart'),
        info: KeyboardListenerComponentExample.description,
      ),
      ExampleUseCase(
        name: 'Hardware Keyboard',
        builder: (_) => GameWidget(game: HardwareKeyboardExample()),
        codeLink: baseLink('input/hardware_keyboard_example.dart'),
        info: HardwareKeyboardExample.description,
      ),
      ExampleUseCase(
        name: 'Mouse Movement',
        builder: (_) => GameWidget(game: MouseMovementExample()),
        codeLink: baseLink('input/mouse_movement_example.dart'),
        info: MouseMovementExample.description,
      ),
      ExampleUseCase(
        name: 'Mouse Cursor',
        builder: (_) => GameWidget(
          game: MouseCursorExample(),
          mouseCursor: SystemMouseCursors.move,
        ),
        codeLink: baseLink('input/mouse_cursor_example.dart'),
        info: MouseCursorExample.description,
      ),
      ExampleUseCase(
        name: 'Long Press',
        builder: (_) => GameWidget(game: LongPressExample()),
        codeLink: baseLink('input/long_press_example.dart'),
        info: LongPressExample.description,
      ),
      ExampleUseCase(
        name: 'Scroll',
        builder: (_) => GameWidget(game: ScrollExample()),
        codeLink: baseLink('input/scroll_example.dart'),
        info: ScrollExample.description,
      ),
      ExampleUseCase(
        name: 'Multitap',
        builder: (_) => GameWidget(game: MultitapExample()),
        codeLink: baseLink('input/multitap_example.dart'),
        info: MultitapExample.description,
      ),
      ExampleUseCase(
        name: 'Multitap Advanced',
        builder: (_) => GameWidget(game: MultitapAdvancedExample()),
        codeLink: baseLink('input/multitap_advanced_example.dart'),
        info: MultitapAdvancedExample.description,
      ),
      ExampleUseCase(
        name: 'Overlapping TapCallbacks',
        builder: (_) => GameWidget(game: OverlappingTapCallbacksExample()),
        codeLink: baseLink('input/overlapping_tap_callbacks_example.dart'),
        info: OverlappingTapCallbacksExample.description,
      ),
      ExampleUseCase(
        name: 'Gesture Hitboxes',
        builder: (_) => GameWidget(game: GestureHitboxesExample()),
        codeLink: baseLink('input/gesture_hitboxes_example.dart'),
        info: GestureHitboxesExample.description,
      ),
      ExampleUseCase(
        name: 'Joystick',
        builder: (_) => GameWidget(game: JoystickExample()),
        codeLink: baseLink('input/joystick_example.dart'),
        info: JoystickExample.description,
      ),
      ExampleUseCase(
        name: 'Joystick Advanced',
        builder: (_) => GameWidget(game: JoystickAdvancedExample()),
        codeLink: baseLink('input/joystick_advanced_example.dart'),
        info: JoystickAdvancedExample.description,
      ),
      ExampleUseCase(
        name: 'Advanced Button',
        builder: (_) => GameWidget(game: AdvancedButtonExample()),
        codeLink: baseLink('input/advanced_button_example.dart'),
        info: AdvancedButtonExample.description,
      ),
      ExampleUseCase(
        name: 'Dynamic Scale & Drag',
        builder: (_) => GameWidget(game: DynamicScaleDragExample()),
        codeLink: baseLink('input/dynamic_scale_drag_example.dart'),
        info: DynamicScaleDragExample.description,
      ),
    ],
  );
}
