import 'package:flame_studio/src/widgets/flame_studio_settings.dart';
import 'package:flutter/widgets.dart';

class ToolbarButton extends StatefulWidget {
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
  State<StatefulWidget> createState() => _ToolbarButtonState();
}

class _ToolbarButtonState extends State<ToolbarButton> {
  bool _isHovered = false;
  bool _isActive = false;

  @override
  Widget build(BuildContext context) {
    final settings = FlameStudioSettings.of(context);
    final painter = CustomPaint(
      painter: _ToolbarButtonPainter(
        widget.disabled,
        _isHovered,
        _isActive,
        widget.icon,
        settings,
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
}

class _ToolbarButtonPainter extends CustomPainter {
  _ToolbarButtonPainter(
    this.isDisabled,
    this.isHovered,
    this.isActive,
    this.icon,
    this.settings,
  );

  final bool isDisabled;
  final bool isHovered;
  final bool isActive;
  final Path icon;
  final FlameStudioSettingsWidget settings;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.height / 20.0;
    canvas.save();
    canvas.scale(size.height / 20.0);

    final radius = Radius.circular(settings.buttonRadius);
    final color = isDisabled
        ? settings.buttonDisabledColor
        : isActive
            ? settings.buttonActiveColor
            : isHovered
                ? settings.buttonHoverColor
                : settings.buttonColor;
    canvas.drawRRect(
      RRect.fromLTRBR(0, 0, size.width / scale, 20.0, radius),
      Paint()..color = color,
    );

    final textColor = isDisabled
        ? settings.buttonDisabledTextColor
        : isActive
            ? settings.buttonActiveTextColor
            : isHovered
                ? settings.buttonHoverTextColor
                : settings.buttonTextColor;
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
}
