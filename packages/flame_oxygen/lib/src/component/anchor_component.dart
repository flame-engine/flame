import 'package:flame/particles.dart';
import 'package:oxygen/oxygen.dart';

export 'package:flame/particles.dart' show Anchor;

class AnchorComponent extends Component<Anchor> {
  late Anchor anchor;

  @override
  void init([Anchor? anchor]) => this.anchor = anchor ?? Anchor.topLeft;

  @override
  void reset() => anchor = Anchor.topLeft;
}
