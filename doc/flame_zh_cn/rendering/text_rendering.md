# Text Rendering

Flame 提供了一些专用类来帮助你渲染文本。


## Text Components

使用 Flame 渲染文本的最简单方法是利用以下提供的文本渲染组件之一：

- `TextComponent`：用于渲染单行文本。
- `TextBoxComponent`：用于在固定大小的盒子内渲染多行文本，并支持打字机效果。你可以使用 `newLineNotifier` 来接收新行添加的通知。使用 `onComplete` 回调在文本完全显示时执行某个函数。
- `ScrollTextBoxComponent`：通过添加垂直滚动功能来增强 `TextBoxComponent` 的功能，当文本超出盒子边界时，可进行滚动显示。

所有组件的演示示例见[此链接](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/rendering/text_example.dart)。


### TextComponent

`TextComponent` 是一个用于渲染单行文本的简单组件。

简单用法：

```dart
class MyGame extends FlameGame {
  @override
  void onLoad() {
    add(
      TextComponent(
        text: 'Hello, Flame',
        position: Vector2.all(16.0),
      ),
    );
  }
}
```

要配置渲染的字体系列、大小、颜色等属性，需要提供（或修改）带有这些信息的 `TextRenderer`；尽管你可以在下文中阅读该接口的更多详细信息，但最简单的实现是 `TextPaint`，它接受一个 Flutter 的 `TextStyle`：

```dart
final regular = TextPaint(
  style: TextStyle(
    fontSize: 48.0,
    color: BasicPalette.white.color,
  ),
);

class MyGame extends FlameGame {
  @override
  void onLoad() {
    add(
      TextComponent(
        text: 'Hello, Flame',
        textRenderer: regular,
        anchor: Anchor.topCenter,
        position: Vector2(size.width / 2, 32.0),
      ),
    );
  }
}
```

你可以在 [TextComponent 的 API](https://pub.dev/documentation/flame/latest/components/TextComponent-class.html) 中找到所有选项。


### TextBoxComponent

`TextBoxComponent` 与 `TextComponent` 非常相似，但正如其名称所示，它用于在边界框内渲染文本，并根据提供的框大小自动换行。

你可以通过 `TextBoxConfig` 中的 `growingBox` 变量来决定盒子是随着文本内容的增多而增长，还是保持静态。静态盒子可以具有固定大小（设置 `TextBoxComponent` 的 `size` 属性），或者自动缩小以适应文本内容。

此外，`align` 属性允许你控制文本内容的水平和垂直对齐方式。例如，将 `align` 设置为 `Anchor.center` 可以在其边界框内水平和垂直居中对齐文本。

如果你想更改盒子的边距，可以使用 `TextBoxConfig` 中的 `margins` 变量。

最后，如果你想模拟“打字”效果，通过实时逐个显示字符串中的每个字符，可以设置 `boxConfig.timePerChar` 参数。

使用示例：

```dart
class MyTextBox extends TextBoxComponent {
  MyTextBox(String text) : super(
    text: text,
    textRenderer: tiny,
    boxConfig: TextBoxConfig(timePerChar: 0.05),
  );

  final bgPaint = Paint()..color = Color(0xFFFF00FF);
  final borderPaint = Paint()..color = Color(0xFF000000)..style = PaintingStyle.stroke;

  @override
  void render(Canvas canvas) {
    Rect rect = Rect.fromLTWH(0, 0, width, height);
    canvas.drawRect(rect, bgPaint);
    canvas.drawRect(rect.deflate(boxConfig.margin), borderPaint);
    super.render(canvas);
  }
}
```


你可以在 [TextBoxComponent 的 API](https://pub.dev/documentation/flame/latest/components/TextBoxComponent-class.html) 中找到所有选项。


### ScrollTextBoxComponent

`ScrollTextBoxComponent` 是 `TextBoxComponent` 的高级版本，专为在限定区域内显示可滚动文本而设计。该组件特别适用于在受限空间内展示大量文本的场景，如对话框或信息面板。

请注意，`TextBoxComponent` 的 `align` 属性在 `ScrollTextBoxComponent` 中不可用。

使用示例：


```dart
class MyScrollableText extends ScrollTextBoxComponent {
  MyScrollableText(Vector2 frameSize, String text) : super(
    size: frameSize,
    text: text,
    textRenderer: regular, 
    boxConfig: TextBoxConfig(timePerChar: 0.05),
  );
}
```


### TextElementComponent

如果你想渲染任意的 `TextElement`，从单个 `InlineTextElement` 到格式化的 `DocumentRoot`，都可以使用 `TextElementComponent`。

一个简单的示例是创建一个 `DocumentRoot` 来渲染包含富文本的一系列块元素（类似于 HTML 中的 “div”）：

```dart
  final document = DocumentRoot([
    HeaderNode.simple('1984', level: 1),
    ParagraphNode.simple(
      'Anything could be true. The so-called laws of nature were nonsense.',
    ),
    // ...
  ]);
  final element = TextElementComponent.fromDocument(
    document: document,
    position: Vector2(100, 50),
    size: Vector2(400, 200),
  );
```

请注意，大小可以通过以下两种方式指定：

- 使用所有 `PositionComponents` 通用的 `size` 属性；或
- 使用应用于 `DocumentStyle` 中的 `width` 和 `height`。

以下是应用样式到文档的示例（该样式可以包含大小以及其他参数）：

```dart
  final style = DocumentStyle(
    width: 400,
    height: 200,
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
    background: BackgroundStyle(
      color: const Color(0xFF4E322E),
      borderColor: const Color(0xFF000000),
      borderWidth: 2.0,
    ),
  );
  final document = DocumentRoot([ ... ]);
  final element = TextElementComponent.fromDocument(
    document: document,
    style: style,
    position: Vector2(100, 50),
  );
```

请参阅更详细的[富文本、格式化文本块渲染示例](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/rendering/rich_text_example.dart)。

有关文本渲染管道底层机制的更多详细信息，请参见下文的“文本元素、文本节点和文本样式”部分。


### Flame Markdown

为了更方便地从带有粗体/斜体的简单字符串到完整结构化文档创建基于富文本的 `DocumentRoot`，Flame 提供了 `flame_markdown` 桥接包，该包将 `markdown` 库与 Flame 的文本渲染基础设施连接起来。

只需使用 `FlameMarkdown` 辅助类和 `toDocument` 方法，将 Markdown 字符串转换为 `DocumentRoot`（然后可以用于创建 `TextElementComponent`）：

```dart
import 'package:flame/text.dart';
import 'package:flame_markdown/flame_markdown.dart';

// ...
final component = await TextElementComponent.fromDocument(
  document: FlameMarkdown.toDocument(
    '# Header\n'
    '\n'
    'This is a **bold** text, and this is *italic*.\n'
    '\n'
    'This is a second paragraph.\n',
  ),
  style: ...,
  position: ...,
  size: ...,
);
```


## Infrastructure

如果你不使用 Flame 组件系统，想了解文本渲染背后的基础设施，想自定义字体和使用的样式，或者想创建自己的自定义渲染器，那么本节内容适合你。

- `TextRenderer`：渲染器知道如何渲染文本；本质上它们包含渲染任意字符串的样式信息。
- `TextElement`：元素是格式化和“布局”的文本片段，包含字符串（“内容”）和样式（“呈现方式”）。

以下图表展示了文本渲染管道的类和继承结构：

```{mermaid}
%%{init: { 'theme': 'dark' } }%%
classDiagram
    %% renderers
    note for TextRenderer "This just the style (how).
    It knows how to take a text string and create a TextElement.
    `render` is just a helper to `format(text).render(...)`. Same for `getLineMetrics`."
    class TextRenderer {
        TextElement format(String text)
        LineMetrics getLineMetrics(String text)
        void render(Canvas canvas, String text, ...)
    }
    class TextPaint
    class SpriteFontRenderer
    class DebugTextRenderer
    
    %% elements
    class TextElement {
        LineMetrics metrics
        render(Canvas canvas, ...)
    }
    class TextPainterTextElement
        
    TextRenderer --> TextPaint
    TextRenderer --> SpriteFontRenderer
    TextRenderer --> DebugTextRenderer

    TextRenderer *-- TextElement
    TextPaint *-- TextPainterTextElement
    SpriteFontRenderer *-- SpriteFontTextElement

    note for TextElement "This is the text (what) and the style (how);
    laid out and ready to render."
    TextElement --> TextPainterTextElement
    TextElement --> SpriteFontTextElement
    TextElement --> Others
```


### TextRenderer

`TextRenderer` 是 Flame 用于渲染文本的抽象类。`TextRenderer` 的实现必须包含关于文本“如何”渲染的信息，例如字体样式、大小、颜色等。它应该能够通过 `format` 方法将这些信息与给定的文本字符串结合起来，以生成一个 `TextElement`。

Flame 提供了三种具体实现：

- `TextPaint`：最常用的实现，使用 Flutter 的 `TextPainter` 渲染常规文本。
- `SpriteFontRenderer`：使用 `SpriteFont`（基于精灵图的字体）渲染位图文本。
- `DebugTextRenderer`：仅用于 Golden 测试。

但如果你想扩展到其他自定义文本渲染形式，也可以提供自己的实现。

`TextRenderer` 的主要工作是将一段文本字符串格式化为 `TextElement`，然后可以将其渲染到屏幕上：

```dart
final textElement = textRenderer.format("Flame is awesome")
textElement.render(...) 
```

然而，渲染器提供了一个辅助方法，可以直接创建元素并进行渲染：

```dart
textRenderer.render(
  canvas,
  'Flame is awesome',
  Vector2(10, 10),
  anchor: Anchor.topCenter,
);
```


#### TextPaint

`TextPaint` 是 Flame 内置的文本渲染实现。它基于 Flutter 的 `TextPainter` 类（因此得名），可以通过样式类 `TextStyle` 进行配置，该类包含渲染文本所需的所有排版信息，如字体大小、颜色、字体系列等。

除了样式外，你还可以选择性地提供一个额外的参数 `textDirection`（通常已设置为 `ltr`，即从左到右）。

使用示例：

```dart
const TextPaint textPaint = TextPaint(
  style: TextStyle(
    fontSize: 48.0,
    fontFamily: 'Awesome Font',
  ),
);
```

注意：有多个包包含 `TextStyle` 类。我们通过 `text` 模块导出正确的（来自 Flutter）版本：

```dart
import 'package:flame/text.dart';
```

但如果你想显式导入它，请确保从 `package:flutter/painting.dart`（或从 material 或 widgets）导入。
如果你还需要导入 `dart:ui`，你可能需要隐藏它的 `TextStyle`，因为该模块包含一个同名的不同类：

```dart
import 'package:flutter/painting.dart';
import 'dart:ui' hide TextStyle;
```

以下是 `TextStyle` 的一些常见属性（查看[`TextStyle` 属性完整列表](https://api.flutter.dev/flutter/painting/TextStyle-class.html)）：

- `fontFamily`：常用字体，如 Arial（默认值），或添加到 `pubspec` 中的自定义字体（参考[如何添加自定义字体](https://docs.flutter.dev/cookbook/design/fonts)）。
- `fontSize`：字体大小，单位为 pt（默认值 `24.0`）。
- `height`：文本行的高度，为字体大小的倍数（默认值为 `null`）。
- `color`：颜色，以 `ui.Color` 的形式表示（默认值为白色）。

有关颜色及其创建方式的更多信息，请参阅[颜色和调色板](palette.md)指南。


#### SpriteFontRenderer

内置的另一种渲染器选项是 `SpriteFontRenderer`，它允许你基于精灵图提供 `SpriteFont`。TODO


#### DebugTextRenderer

该渲染器用于 Golden 测试。在 Golden 测试中渲染基于字体的常规文本并不可靠，因为不同平台的字体定义存在差异，并且使用的抗锯齿算法也不同。
该渲染器会将文本渲染为每个单词都是一个实心矩形，从而可以测试元素的布局、定位和大小，而无需依赖基于字体的渲染。


## Inline Text Elements

`TextElement` 是一个“预编译”的文本片段，已经应用了特定样式，并进行了格式化和布局，可以在任意位置进行渲染。

`InlineTextElement` 实现了 `TextElement` 接口，并且必须实现两个方法，一个用于指示如何移动它，另一个用于将其绘制到画布上：

```dart
  void translate(double dx, double dy);
  void draw(Canvas canvas);
```

这些方法是供 `InlineTextElement` 的实现类重写的，并且可能不会被用户直接调用；因为已经提供了一个方便的 `render` 方法：

```dart
  void render(
    Canvas canvas,
    Vector2 position, {
    Anchor anchor = Anchor.topLeft,
  })
```

该方法允许元素使用指定的锚点在特定位置进行渲染。

该接口还规定（并提供）与 `InlineTextElement` 关联的 `LineMetrics` 对象的 getter，这使得你（以及 `render` 实现）能够访问与元素相关的大小信息（宽度、高度、上升线等）。

```dart
  LineMetrics get metrics;
```


## Text Elements, Text Nodes, and Text Styles

尽管常规渲染器总是直接与 `InlineTextElement` 一起工作，但它们背后有一个更大的基础架构，可以用来渲染更加丰富或格式化的文本。

文本元素（Text Elements）是行内文本元素（Inline Text Elements）的超集，它们表示富文本文档中的任意渲染块。本质上，它们是具体且“物理化”的：它们是准备好渲染到画布上的对象。

这一特性将文本元素与文本节点区分开来。文本节点是结构化的文本片段；而文本样式（在代码中称为 `FlameTextStyle`，以便更容易与 Flutter 的 `TextStyle` 配合使用）是用于描述任意文本片段应如何渲染的描述符。

因此，在最常见的情况下，用户将使用 `TextNode` 来描述所需的富文本片段；定义应用于其的 `FlameTextStyle`；并使用它来生成 `TextElement`。根据渲染类型，生成的 `TextElement` 将是 `InlineTextElement`，这将把我们带回到常规的渲染管道流程。行内文本类型元素的独特属性在于，它公开了一个可以用于高级渲染的 `LineMetrics`，而其他元素仅公开了一个更简单的 `draw` 方法，并不涉及大小和定位。

然而，如果目的是创建一个包含多个块或段落、并带有格式化文本的完整文档，则必须使用其他类型的文本元素、文本节点和文本样式。要渲染任意 `TextElement`，也可以使用 `TextElementComponent`（见上文）。

See [examples of such usage](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/rendering/rich_text_example.dart).


### Text Nodes and the Document Root

`DocumentRoot` 本身不是 `TextNode`（从继承角度来看），而是表示一组 `BlockNodes`，用于布局包含多个块或段落的富文本“页面”或“文档”。它代表整个文档，并且可以接收全局样式。

定义富文本文档的第一步是创建一个节点，该节点通常是 `DocumentRoot`。

它首先包含最顶层的块节点列表，可以用于定义标题、段落或列。

然后，这些块中的每个块可以包含其他块或行内文本节点，包括纯文本节点或带有特定格式的富文本。

请注意，节点结构定义的层次结构也用于样式应用，如 `FlameTextStyle` 类中定义的那样。

所有实际节点都继承自 `TextNode`，其结构如下图所示：

```{mermaid}
%%{init: { 'theme': 'dark' } }%%
graph TD
    %% Config %%
    classDef default fill:#282828,stroke:#F6BE00;

    %% Nodes %%
    TextNode("
        <big><strong>TextNode</strong></big>
        Can be thought of as an HTML DOM node;
        each subclass can be thought of as a specific tag.
    ")
    BlockNode("
        <big><strong>BlockNode</strong></big>
        #quot;div#quot;
    ")
    InlineTextNode("
        <big><strong>InlineTextNode</strong></big>
        #quot;span#quot;
    ")
    ColumnNode("
        <big><strong>ColumnNode</strong></big>
        column-arranged group of other Block Nodes
    ")
    TextBlockNode("
        <big><strong>TextBlockNode</strong></big>
        a #quot;div#quot; with an InlineTextNode as a direct child
    ")
    HeaderNode("
        <big><strong>HeaderNode</strong></big>
        #quot;h1#quot; / #quot;h2#quot; / etc
    ")
    ParagraphNode("
        <big><strong>ParagraphNode</strong></big>
        #quot;p#quot;
    ")
    GroupTextNode("
        <big><strong>GroupTextNode</strong></big>
        groups other TextNodes in a single line
    ")
    PlainTextNode("
        <big><strong>PlainTextNode</strong></big>
        just plain text, unformatted
    ")
    ItalicTextNode("
        <big><strong>ItalicTextNode</strong></big>
        #quot;i#quot; / #quot;em#quot;
    ")
    BoldTextNode("
        <big><strong>BoldTextNode</strong></big>
        #quot;b#quot; / #quot;strong#quot;
    ")
    TextNode ----> BlockNode
    TextNode --------> InlineTextNode
    BlockNode --> ColumnNode
    BlockNode --> TextBlockNode
    TextBlockNode --> HeaderNode
    TextBlockNode --> ParagraphNode
    InlineTextNode --> GroupTextNode
    InlineTextNode --> PlainTextNode
    InlineTextNode --> BoldTextNode
    InlineTextNode --> ItalicTextNode
```


### (Flame) Text Styles

文本样式可以应用于节点以生成元素。所有样式都继承自 `FlameTextStyle` 抽象类（这样命名是为了避免与 Flutter 的 `TextStyle` 混淆）。

它们遵循树状结构，始终以 `DocumentStyle` 作为根节点；这种结构被用来将级联样式应用于对应的节点结构。事实上，它们与 CSS 定义非常相似，可以将其视为 CSS 定义。

完整的继承链可以在下图中查看：

```{mermaid}
%%{init: { 'theme': 'dark' } }%%
classDiagram
    %% Nodes %%
    class FlameTextStyle {
        copyWith()
        merge()
    }

    note for FlameTextStyle "Root for all styles.
    Not to be confused with Flutter's TextStyle."

    class DocumentStyle {
        <<for the entire Document Root>>
        size
        padding
        background [BackgroundStyle]
        specific styles [for blocks & inline]
    }

    class BlockStyle {
        <<for Block Nodes>>
        margin, padding
        background [BackgroundStyle]
        text [InlineTextStyle]
    }

    class BackgroundStyle {
        <<for Block or Document>>
        color
        border
    }

    class InlineTextStyle {
        <<for any nodes>>
        font, color
    }

    FlameTextStyle <|-- DocumentStyle
    FlameTextStyle <|-- BlockStyle
    FlameTextStyle <|-- BackgroundStyle
    FlameTextStyle <|-- InlineTextStyle
```


### Text Elements

最后，我们有了元素，它表示节点（“内容”）与样式（“呈现方式”）的组合，因此，它们表示预编译、布局好的富文本片段，可以在 Canvas 上渲染。

行内文本元素（Inline Text Elements）可以被视为 `TextRenderer`（简化的“呈现方式”）与字符串（单行“内容”）的组合。

这是因为 `InlineTextStyle` 可以通过 `asTextRenderer` 方法转换为特定的 `TextRenderer`，然后用于将每一行文本布局成一个独特的 `InlineTextElement`。

直接使用渲染器时，整个布局过程会被跳过，并返回一个 `TextPainterTextElement` 或 `SpriteFontTextElement`。

可以看到，从本质上讲，元素的两种定义在所有方面都等效。但这仍然为我们留下了两种渲染文本的路径。选择哪种方式？如何解决这个难题？

如果不确定，可以参考以下准则帮助你选择最适合的方式：

- 如果要以最简单的方式渲染文本，请使用 `TextPaint`（基础渲染器实现）
  - 可以使用 FCS 提供的 `TextComponent` 组件。
- 如果要渲染精灵字体，必须使用 `SpriteFontRenderer`（接受 `SpriteFont` 的渲染器实现）；
- 如果要渲染多行文本，并自动换行，有两种选择：
  - 使用 FCS 的 `TextBoxComponent`，它使用任意文本渲染器将每行文本绘制为一个元素，并执行其自身的布局和换行；
  - 使用文本节点和样式系统创建预先布局的元素。注意：目前没有与之配套的 FCS 组件。
- 最后，如果要使用格式化（或富文本），则必须使用文本节点和样式。
