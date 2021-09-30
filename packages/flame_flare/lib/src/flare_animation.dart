part of flame_flare;

/// A class that wraps all the settings of a flare animation from [filename].
///
/// It has a similar API to the [FlareActor] widget.
class FlareActorAnimation {
  FlareActorAnimation(
    this.filename, {
    this.boundsNode,
    this.animation,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.isPaused = false,
    this.snapToEnd = false,
    this.controller,
    this.callback,
    this.color,
    this.shouldClip = true,
    this.sizeFromArtboard = false,
    this.artboard,
    this.useAntialias = true,
  }) : flareProvider = null;

  FlareActorAnimation.asset(
    this.flareProvider, {
    this.boundsNode,
    this.animation,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.isPaused = false,
    this.snapToEnd = false,
    this.controller,
    this.callback,
    this.color,
    this.shouldClip = true,
    this.sizeFromArtboard = false,
    this.artboard,
    this.useAntialias = true,
  }) : filename = null;

  FlareActorRenderObject? _renderObject;

  // Flare only allows the render box to be loaded if it is considered "attached", we need this ugly dumb thing here to do that.
  final _pipelineOwner = _FlareActorComponentPipelineOwner();

  // Fields are ported from flare actor widget
  /// Mirror to [FlareActor.filename]
  final String? filename;

  /// Mirror to [FlareActor.flareProvider]
  final AssetProvider? flareProvider;

  /// Mirror to [FlareActor.artboard]
  final String? artboard;

  /// Mirror to [FlareActor.animation]
  final String? animation;

  /// Mirror to [FlareActor.snapToEnd]
  final bool snapToEnd;

  /// Mirror to [FlareActor.fit]
  final BoxFit fit;

  /// Mirror to [FlareActor.alignment]
  final Alignment alignment;

  /// Mirror to [FlareActor.isPaused]
  final bool isPaused;

  /// Mirror to [FlareActor.shouldClip]
  final bool shouldClip;

  /// Mirror to [FlareActor.controller]
  final FlareController? controller;

  /// Mirror to [FlareActor.callback]
  final FlareCompletedCallback? callback;

  /// Mirror to [FlareActor.color]
  final Color? color;

  /// Mirror to [FlareActor.boundsNode]
  final String? boundsNode;

  /// Mirror to [FlareActor.sizeFromArtboard]
  final bool sizeFromArtboard;

  /// When false disables antialiasing on drawables.
  final bool useAntialias;

  void init() {
    _renderObject = _generateRenderObject();
  }

  FlareActorRenderObject _generateRenderObject() {
    final renderObject = FlareActorRenderObject()
      ..assetProvider =
          flareProvider ?? AssetFlare(bundle: Flame.bundle, name: filename)
      ..alignment = alignment
      ..animationName = animation
      ..snapToEnd = snapToEnd
      ..isPaused = isPaused
      ..controller = controller
      ..completed = callback
      ..color = color
      ..shouldClip = shouldClip
      ..boundsNodeName = boundsNode
      ..useIntrinsicSize = sizeFromArtboard
      ..artboardName = artboard
      ..useAntialias = useAntialias;

    _loadRenderBox(renderObject);
    return renderObject;
  }

  void render(Canvas canvas, Vector2 size) {
    final renderObject = _renderObject;
    if (renderObject == null) {
      throw 'FlareActorAnimation was rendered before initialization. Run FlareActorAnimation.init() before rendering it';
    }
    // dart doesn't understand this can be null
    final bounds = renderObject.aabb as AABB?;
    if (bounds != null) {
      _paintActor(canvas, bounds, size);
    }
  }

  void advance(double dt) {
    final renderObject = _renderObject;
    if (renderObject == null) {
      throw 'FlareActorAnimation was advanced before initialization. Run FlareActorAnimation.init() before calling .advance';
    }
    renderObject.advance(dt);
  }

  void destroy() {
    final renderObject = _renderObject;
    if (renderObject == null) {
      throw 'FlareActorAnimation was destroyed before initialization. Run FlareActorAnimation.init() before destroying it';
    }
    renderObject.dispose();
  }

  void _loadRenderBox(FlareActorRenderObject renderObject) {
    renderObject.attach(_pipelineOwner);
    if (!renderObject.warmLoad()) {
      renderObject.coldLoad();
    }
  }

  // Paint procedures ported from FlareRenderBox.paint with some changes that
  // makes sense on a flame context
  void _paintActor(Canvas c, AABB bounds, Vector2 size) {
    final renderObject = _renderObject;
    if (renderObject == null) {
      throw 'FlareActorAnimation was rendered before initialization. Run FlareActorAnimation.init() before rendering it';
    }

    final contentWidth = bounds[2] - bounds[0];
    final contentHeight = bounds[3] - bounds[1];
    final x = -1 * bounds[0] -
        contentWidth / 2.0 -
        (alignment.x * contentWidth / 2.0);
    final y = -1 * bounds[1] -
        contentHeight / 2.0 -
        (alignment.y * contentHeight / 2.0);

    double scaleX = 1.0, scaleY = 1.0;

    c.save();
    // pre paint
    if (shouldClip) {
      c.clipRect(size.toRect());
    }

    // boxfit
    switch (fit) {
      case BoxFit.fill:
        scaleX = size.x / contentWidth;
        scaleY = size.y / contentHeight;
        break;
      case BoxFit.contain:
        double minScale = min(size.x / contentWidth, size.y / contentHeight);
        scaleX = scaleY = minScale;
        break;
      case BoxFit.cover:
        double maxScale = max(size.x / contentWidth, size.y / contentHeight);
        scaleX = scaleY = maxScale;
        break;
      case BoxFit.fitHeight:
        double minScale = size.y / contentHeight;
        scaleX = scaleY = minScale;
        break;
      case BoxFit.fitWidth:
        double minScale = size.x / contentWidth;
        scaleX = scaleY = minScale;
        break;
      case BoxFit.none:
        scaleX = scaleY = 1.0;
        break;
      case BoxFit.scaleDown:
        double minScale = min(size.x / contentWidth, size.y / contentHeight);
        scaleX = scaleY = minScale < 1.0 ? minScale : 1.0;
        break;
    }

    final halfSize = size / 2;
    final transform = Mat2D();
    transform[4] = halfSize.x + (alignment.x * halfSize.x);
    transform[5] = halfSize.y + (alignment.y * halfSize.y);
    Mat2D.scale(transform, transform, Vec2D.fromValues(scaleX, scaleY));
    final center = Mat2D();
    center[4] = x;
    center[5] = y;
    Mat2D.multiply(transform, transform, center);

    c.translateVector(
      halfSize +
          Vector2(
            alignment.x * halfSize.x,
            alignment.y * halfSize.y,
          ),
    );

    c.scale(scaleX, scaleY);
    c.translate(x, y);

    renderObject.paintFlare(c, transform);
    c.restore();
    renderObject.postPaint(c, Offset.zero);
  }
}
