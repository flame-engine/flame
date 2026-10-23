import 'package:flame_studio/src/core/theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A single-line text field in the style of the studio.
///
/// It is built on top of [EditableText], so that the studio does not depend on
/// the Material library. While the field is not focused it shows [value].
/// Edits are reported through [onChanged] as they are typed, and through
/// [onSubmitted] when the user presses Enter or the field loses focus. Pressing
/// Escape discards the edit.
class const StudioTextField({
  required final String value,
  final ValueChanged<String>? onChanged,
  final ValueChanged<String>? onSubmitted,
  final String? placeholder,
  final bool selectAllOnFocus = false,
  super.key,
}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<StudioTextField> createState() => _StudioTextFieldState();
}

class _StudioTextFieldState() extends ConsumerState<StudioTextField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value,
  );
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(StudioTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && _controller.text != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      if (widget.selectAllOnFocus) {
        _controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _controller.text.length,
        );
      }
    } else if (_controller.text != widget.value) {
      widget.onSubmitted?.call(_controller.text);
    }
    setState(() {});
  }

  void _cancel() {
    _controller.text = widget.value;
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final textStyle = TextStyle(
      color: theme.textColor,
      fontSize: theme.fontSize,
    );
    final placeholder = widget.placeholder;

    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): _cancel},
      child: MouseRegion(
        cursor: SystemMouseCursors.text,
        child: Container(
          height: theme.rowHeight - 2,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: theme.fieldColor,
            border: Border.all(
              color: _focusNode.hasFocus
                  ? theme.accentColor
                  : theme.fieldBorderColor,
            ),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              if (placeholder != null)
                ValueListenableBuilder(
                  valueListenable: _controller,
                  builder: (context, value, _) => value.text.isEmpty
                      ? Text(
                          placeholder,
                          style: textStyle.copyWith(color: theme.dimTextColor),
                        )
                      : const SizedBox.shrink(),
                ),
              EditableText(
                controller: _controller,
                focusNode: _focusNode,
                style: textStyle,
                cursorColor: theme.accentColor,
                backgroundCursorColor: theme.dimTextColor,
                selectionColor: theme.accentColor.withAlpha(0x80),
                cursorWidth: 1.0,
                onChanged: widget.onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
