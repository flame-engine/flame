import 'package:flame_studio/src/core/theme.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ToolbarButton extends ConsumerStatefulWidget {
  const ToolbarButton({
    required this.icon,
    this.onClick,
    this.disabled = false,
    super.key,
  });

  final void Function()? onClick;
  final Path icon;
  final bool disabled;

  @override
  ToolbarButtonState createState() => ToolbarButtonState();
}

class ToolbarButtonState extends ConsumerState<ToolbarButton> {
  bool _isHovered = false;
  bool _isActive = false;

  @override
  Widget build(BuildContext context) {
    final painter = CustomPaint(
      painter: _ToolbarButtonPainter(
        widget.icon,
        ref.watch(themeProvider),
        isDisabled: widget.disabled,
        isHovered: _isHovered,
        isActive: _isActive,
      ),
    );

    return AspectRatio(
      aspectRatio: 1.25,
      child: widget.disabled
          ? painter
          : MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTapDown: (_) => setState(() => _isActive = true),
                onTapCancel: () => setState(() => _isActive = false),
                onTapUp: (_) {
                  if (_isActive) {
                    widget.onClick?.call();
                  }
                  setState(() => _isActive = false);
                },
                child: painter,
              ),
            ),
    );
  }

  @override
  void didUpdateWidget(ToolbarButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.icon != oldWidget.icon ||
        widget.disabled != oldWidget.disabled) {
      _isActive = false;
      _isHovered = false;
    }
  }
}

enum _ToolbarButtonRenderState {
  disabled,
  active,
  hovered,
  normal,
}

class _ToolbarButtonPainter extends CustomPainter {
  _ToolbarButtonPainter(
    this.icon,
    this.theme, {
    required this.isDisabled,
    required this.isHovered,
    required this.isActive,
  });

  final bool isDisabled;
  final bool isHovered;
  final bool isActive;
  final Path icon;
  final Theme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.height / 20.0;
    canvas.save();
    canvas.scale(size.height / 20.0);

    final renderState = _renderState;

    final radius = Radius.circular(theme.buttonRadius);
    final color = switch (renderState) {
      _ToolbarButtonRenderState.disabled => theme.buttonDisabledColor,
      _ToolbarButtonRenderState.active => theme.buttonActiveColor,
      _ToolbarButtonRenderState.hovered => theme.buttonHoverColor,
      _ToolbarButtonRenderState.normal => theme.buttonColor,
    };
    canvas.drawRRect(
      RRect.fromLTRBR(0, 0, size.width / scale, 20.0, radius),
      Paint()..color = color,
    );

    final textColor = switch (renderState) {
      _ToolbarButtonRenderState.disabled => theme.buttonDisabledTextColor,
      _ToolbarButtonRenderState.active => theme.buttonActiveTextColor,
      _ToolbarButtonRenderState.hovered => theme.buttonHoverTextColor,
      _ToolbarButtonRenderState.normal => theme.buttonTextColor,
    };
    canvas.translate(size.width / scale / 2, 10);
    canvas.drawPath(icon, Paint()..color = textColor);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ToolbarButtonPainter old) {
    return isHovered != old.isHovered ||
        isActive != old.isActive ||
        isDisabled != old.isDisabled ||
        icon != old.icon;
  }

  _ToolbarButtonRenderState get _renderState {
    if (isDisabled) {
      return _ToolbarButtonRenderState.disabled;
    }
    if (isActive) {
      return _ToolbarButtonRenderState.active;
    }
    if (isHovered) {
      return _ToolbarButtonRenderState.hovered;
    }
    return _ToolbarButtonRenderState.normal;
  }
}
