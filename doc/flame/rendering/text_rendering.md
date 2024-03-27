# Text Rendering

Flame has some dedicated classes to help you render text.


## Text Components

The simplest way to render text with Flame is to leverage one of the provided text-rendering
components:

- `TextComponent` for rendering a single line of text
- `TextBoxComponent` for bounding multi-line text within a sized box, including the possibility of a
typing effect
- `ScrollTextBoxComponent` enhances the functionality of `TextBoxComponent` by adding scrolling
capability when the text exceeds the boundaries of the enclosing box.

Use the `onFinished` callback to get notified when the text is completely printed.


All components are showcased in
[this example](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/rendering/text_example.dart).


### TextComponent

`TextComponent` is a simple component that renders a single line of text.

Simple usage:

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

In order to configure aspects of the rendering like font family, size, color, etc, you need to
provide (or amend) a `TextRenderer` with such information; while you can read more details about
this interface below, the simplest implementation you can use is the `TextPaint`, which takes a
Flutter `TextStyle`:

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

You can find all the options under [TextComponent's
API](https://pub.dev/documentation/flame/latest/components/TextComponent-class.html).


### TextBoxComponent

`TextBoxComponent` is very similar to `TextComponent`, but as its name suggest it is used to render
text inside a bounding box, creating line breaks according to the provided box size.

You can decide if the box should grow as the text is written or if it should be static by the
`growingBox` variable in the `TextBoxConfig`. A static box could either have a fixed size (setting
the `size` property of the `TextBoxComponent`), or to automatically shrink to fit the text content.

In addition, the `align` property allows you to control the the horizontal and vertical alignment of
the text content. For example, setting `align` to `Anchor.center` will center the text within its
bounding box both vertically and horizontally.

If you want to change the margins of the box use the `margins` variable in the `TextBoxConfig`.

Finally, if you want to simulate a "typing" effect, by showing each character of the string one by
one as if being typed in real-time, you can provide the `boxConfig.timePerChar` parameter.

Example usage:

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


You can find all the options under [TextBoxComponent's
API](https://pub.dev/documentation/flame/latest/components/TextBoxComponent-class.html).


### ScrollTextBoxComponent

The `ScrollTextBoxComponent` is an advanced version of the `TextBoxComponent`,
designed for displaying scrollable text within a defined area.
This component is particularly useful for creating interfaces where large amounts of text
need to be presented in a constrained space, such as dialogues or information panels.

Note that the `align` property of `TextBoxComponent` is not available.


Example usage:


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

If you want to render an arbitrary TextElement, ranging from a single InlineTextElement to a
formatted DocumentRoot, you can use the `TextElementComponent`.

A simple example is to create a DocumentRoot to render a sequence of block elements (think of an
HTML "div") containing rich text:

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

Note that the size can be specified in two ways; either via:

- the size property common to all `PositionComponents`; or
- the width/height included within the `DocumentStyle` applied.

An example applying a style to the document (which can include the size but other parameters as
well):

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

For a more elaborate example of rich-text, formatted text blocks rendering, check [this
example](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/rendering/rich_text_example.dart).

For more details about the underlying mechanics of the text rendering pipeline, see "Text Elements,
Text Nodes, and Text Styles" below.


### Flame Markdown

In order to more easily create rich-text-based DocumentRoots, from simple strings with bold/italics
to complete structured documents, Flame provides the `flame_markdown` bridge package that connects
the `markdown` library with Flame's text rendering infrastructure.

Just use the `FlameMarkdown` helper class and the `toDocument` method to convert a markdown string
into a DocumentRoot (which can then be used to create a `TextElementComponent`):

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

If you are not using the Flame Component System, want to understand the infrastructure behind text
rendering, want to customize fonts and styles used, or want to create your own custom renderers,
this section is for you.

- `TextRenderer`: renderers know "how" to render text; in essence they contain the style information
  to render any string
- `TextElement`: an element is formatted, "laid-out" piece of text, include the string ("what") and
  the style ("how")

The following diagram showcases the class and inheritance structure of the text rendering pipeline:

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

`TextRenderer` is the abstract class used by Flame to render text. Implementations of `TextRenderer`
must include the information about the "how" the text is rendered. Font style, size, color, etc. It
should be able to combine that information with a given string of text, via the `format` method, to
generate a `TextElement`.

Flame provides two concrete implementations:

- `TextPaint`: most used, uses Flutter `TextPainter` to render regular text
- `SpriteFontRenderer`: uses a `SpriteFont` (a sprite sheet-based font) to render bitmap text
- `DebugTextRenderer`: only intended to be used for Golden Tests

But you can also provide your own if you want to extend to other customized forms of text rendering.

The main job of a `TextRenderer` is to format a string of text into a `TextElement`, that then can
be rendered onto the screen:

```dart
final textElement = textRenderer.format("Flame is awesome")
textElement.render(...) 
```

However the renderer provides a helper method to directly create the element and render it:

```dart
textRenderer.render(
  canvas,
  'Flame is awesome',
  Vector2(10, 10),
  anchor: Anchor.topCenter,
);
```


#### TextPaint

`TextPaint` is the built-in implementation of text rendering in Flame. It is based on top of
Flutter's `TextPainter` class (hence the name), and it can be configured by the style class
`TextStyle`, which contains all typographical information required to render text; i.e., font size
and color, font family, etc.

Outside of the style you can also optionally provide one extra parameter which is the
`textDirection` (but that is typically already set to `ltr` or left-to-right).

Example usage:

```dart
const TextPaint textPaint = TextPaint(
  style: TextStyle(
    fontSize: 48.0,
    fontFamily: 'Awesome Font',
  ),
);
```

Note: there are several packages that contain the class `TextStyle`. We export the right one (from
Flutter) via the `text` module:

```dart
import 'package:flame/text.dart';
```

But if you want to import it explicitly, make sure that you import it from
`package:flutter/painting.dart` (or from material or widgets). If you also need to import `dart:ui`,
you might need to hide its version of `TextStyle`, since that module contains a different class with
the same name:

```dart
import 'package:flutter/painting.dart';
import 'dart:ui' hide TextStyle;
```

Following are some common properties of `TextStyle`(see the [full
list of `TextStyle` properties](https://api.flutter.dev/flutter/painting/TextStyle-class.html)):

- `fontFamily`: a commonly available font, like Arial (default), or a custom font added in your
 pubspec (see [how to add a custom font](https://docs.flutter.dev/cookbook/design/fonts)).
- `fontSize`: font size, in pts (default `24.0`).
- `height`: height of text line, as a multiple of font size (default `null`).
- `color`: the color, as a `ui.Color` (default white).

For more information regarding colors and how to create them, see the [Colors and the
Palette](palette.md) guide.


#### SpriteFontRenderer

The other renderer option provided out of the box is `SpriteFontRenderer`, which allows you to
provide a `SpriteFont` based off of a sprite sheet. TODO


#### DebugTextRenderer

This renderer is intended to be used for Golden Tests. Rendering normal font-based text in Golden
Tests is unreliable due to differences in font definitions across platforms and different algorithms
used for anti-aliasing. This renderer will render text as if each word was a solid rectangle, making
it possible to test the layout, positioning and sizing of the elements without having to rely on
font-based rendering.


## Inline Text Elements

A `TextElement` is a "pre-compiled", formatted and laid-out piece of text with a specific styling
applied, ready to be rendered at any given position.

A `InlineTextElement` implements the `TextElement` interface and must implement their two methods,
one that teaches how to translate it around and another on how to draw it to the canvas:

```dart
  void translate(double dx, double dy);
  void draw(Canvas canvas);
```

These methods are intended to be overwritten by the implementations of `InlineTextElement`, and
probably will not be called directly by users; because a convenient `render` method is provided:

```dart
  void render(
    Canvas canvas,
    Vector2 position, {
    Anchor anchor = Anchor.topLeft,
  })
```

That allows the element to be rendered at a specific position, using a given anchor.

The interface also mandates (and provides) a getter for the `LineMetrics` object associated with
that `InlineTextElement`, which allows you (and the `render` implementation) to access sizing
information related to the element (width, height, ascend, etc).

```dart
  LineMetrics get metrics;
```


## Text Elements, Text Nodes, and Text Styles

While normal renderers always work with a `InlineTextElement` directly, there is a bigger underlying
infrastructure that can be used to render more rich or formatter text.

Text Elements are a superset of Inline Text Elements that represent an arbitrary rendering block
within a rich-text document. Essentially, they are concrete and "physical": they are objects that
are ready to be rendered on a canvas.

This property distinguishes them from Text Nodes, which are structured pieces of text, and from Text
Styles (called `FlameTextStyle` in code to make it easier to work alongside Flutter's `TextStyle`),
which are descriptors for how arbitrary pieces of text ought to be rendered.

So, in the most general case, a user would use a `TextNode` to describe a desired piece of rich
text; define a `FlameTextStyle` to apply to it; and use that to generate a `TextElement`. Depending
on the type of rendering, the `TextElement` generated will be an `InlineTextElement`, which brings
us back to the normal flow of the rendering pipeline. The unique property of the Inline-Text-type
element is that it exposes a LineMetrics that can be used for advanced rendering; while the other
elements only expose a simpler `draw` method which is unaware of sizing and positioning.

However, the other types of Text Elements, Text Nodes, and Text Styles must be used if the intent is
to create an entire document (multiple blocks or paragraphs), enriched with formatted text. In order
to render an arbitrary TextElement, you can alternatively use the `TextElementComponent` (see above).

An example of such usages can be seen in [this
example](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/rendering/rich_text_example.dart).


### Text Nodes and the Document Root

A `DocumentRoot` is not a `TextNode` (inheritance-wise) in itself but represents a grouping of
`BlockNodes` that layout a "page" or "document" of rich text laid out in multiple blocks or
paragraphs. It represents the entire document and can receive a global Style.

The first step to define your rich-text document is to create a Node, which will likely be a
`DocumentRoot`.

It will first contain the top-most list of Block Nodes that can define headers, paragraphs or
columns.

Then each of those blocks can contain other blocks or the Inline Text Nodes, either Plain Text Nodes
or some rich-text with specific formatting.

Note that the hierarchy defined by the node structure is also used for styling purposes as per
defined in the `FlameTextStyle` class.

The actual nodes all inherit from `TextNode` and are broken down by the following diagram:

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

Text Styles can be applied to nodes to generate elements. They all inherit from `FlameTextStyle`
abstract class (which is named as is to avoid confusion with Flutter's `TextStyle`).

They follow a tree-like structure, always having `DocumentStyle` as the root; this structure is
leveraged to apply cascading style to the analogous Node structure. In fact, they are pretty similar
to, and can be thought of as, CSS definitions.

The full inheritance chain can be seen on the following diagram:

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

Finally, we have the elements, that represent a combination of a node ("what") with a style ("how"),
and therefore represent a pre-compiled, laid-out piece of rich text to be rendered on the Canvas.

Inline Text Elements specifically can alternatively be thought of as a combination of a
`TextRenderer` (simplified "how") and a string (single line of "what").

That is because an `InlineTextStyle` can be converted to a specific `TextRenderer` via the
`asTextRenderer` method, which is then used to lay out each line of text into a unique
`InlineTextElement`.

When using the renderer directly, the entire layout process is skipped, and a single
`TextPainterTextElement` or `SpriteFontTextElement` is returned.

As you can see, both definitions of an Element are, essentially, equivalent, all things considered.
But it still leaves us with two paths for rendering text. Which one to pick? How to solve this
conundrum?

When in doubt, the following guidelines can help you picking the best path for you:

- for the simplest way to render text, use `TextPaint` (basic renderer implementation)
  - you can use the FCS provided component `TextComponent` for that.
- for rendering Sprite Fonts, you must use `SpriteFontRenderer` (a renderer implementation that
  accepts a `SpriteFont`);
- for rendering multiple lines of text, with automatic line breaks, you have two options:
  - use the FCS `TextBoxComponent`, which uses any text renderer to draw each line of text as an
    Element, and does its own layout and line breaking;
  - use the Text Node & Style system to create your pre-laid-out Elements. Note: there is no current
    FCS component for it.
- finally, in order to have formatted (or rich) text, you must use Text Nodes & Styles.
