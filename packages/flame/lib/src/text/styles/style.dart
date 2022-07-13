import 'package:meta/meta.dart';

abstract class Style {
  Style? _parent;

  Style clone();

  @protected
  S acquire<S extends Style>(S style) {
    final useStyle = style._parent == null ? style : style.clone() as S;
    useStyle._parent = this;
    return useStyle;
  }
}
