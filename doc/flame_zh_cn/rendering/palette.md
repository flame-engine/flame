# Palette

在你的游戏中，你需要在许多地方使用颜色。在 `dart:ui` 中有两个类可以使用，分别是 `Color` 和 `Paint`。

`Color` 类表示一种以十六进制整数格式的 ARGB 颜色。因此，要创建一个 `Color` 实例，只需将颜色作为 ARGB 格式的整数传递即可。

<!--- cSpell:ignore AARRGGBB -->
你可以使用 Dart 的十六进制表示法来简化操作；例如：`0xFF00FF00` 表示完全不透明的绿色（格式为 `0xAARRGGBB`）。

**注意**：前两个十六进制数字表示 alpha 通道（透明度），这与常规的（非 A）RGB 不同。前两位数字的最大值 (FF = 255) 表示完全不透明，最小值 (00 = 0) 表示完全透明。

在 Material Flutter 包中，存在一个 `Colors` 类，它提供了一些常用颜色的常量：

```dart
import 'package:flutter/material.dart' show Colors;

const black = Colors.black;
```

有些更复杂的方法可能还会接受一个 `Paint` 对象，它是一个更完整的结构，可以配置与描边、颜色、滤镜和混合相关的各种属性。不过，通常即使在使用较复杂的 API 时，你也只希望拥有一个表示单一纯色的 `Paint` 实例。

**注意**：我们不建议每次需要特定的 `Paint` 时都创建一个新的 `Paint` 对象，因为这可能会导致创建大量不必要的对象。更好的做法是将 `Paint` 对象定义在某个地方并重复使用（但要注意 `Paint` 类是可变的，不像 `Color`），或者使用 `Palette` 类来定义你在游戏中需要使用的所有颜色。

你可以这样创建一个对象：

```dart
Paint green = Paint()..color = const Color(0xFF00FF00);
```

为帮助你管理颜色并保持游戏的色彩一致性，Flame 提供了 `Palette` 类。你可以使用它在需要的地方轻松访问 `Color` 和 `Paint`，并将游戏中使用的颜色定义为常量，这样就不会混淆颜色。

`BasicPalette` 类是调色板的一个示例，它添加了黑色和白色作为颜色。因此，你可以直接从 `BasicPalette` 中访问黑色或白色；例如，使用 `color`：

```dart
TextConfig regular = TextConfig(color: BasicPalette.white.color);
```

或者使用 `paint`:

```dart
canvas.drawRect(rect, BasicPalette.black.paint);
```

然而，理想情况下，你可以根据 `BasicPalette` 的示例创建你自己的调色板，并添加游戏的颜色调色板/配色方案。这样你就可以在组件和类中静态访问任何颜色。
以下是 [示例游戏 BGUG](https://github.com/bluefireteam/bgug/blob/master/lib/palette.dart) 中 `Palette` 实现的示例：

```dart
import 'dart:ui';

import 'package:flame/palette.dart';

class Palette {
  static PaletteEntry white = BasicPalette.white;

  static PaletteEntry toastBackground = PaletteEntry(Color(0xFFAC3232));
  static PaletteEntry toastText = PaletteEntry(Color(0xFFDA9A00));

  static PaletteEntry grey = PaletteEntry(Color(0xFF404040));
  static PaletteEntry green = PaletteEntry(Color(0xFF54a286));
}
```

`PaletteEntry` 是一个 `const` 类，用于保存颜色信息，并包含以下成员：

- `color`：返回指定的 `Color`。
- `paint`：使用指定的颜色创建一个新的 `Paint`。由于 `Paint` 是一个非 `const` 类，因此该方法每次调用时都会创建一个全新的实例。可以安全地对其进行级联修改。
