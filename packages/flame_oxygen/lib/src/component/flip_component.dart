import 'package:oxygen/oxygen.dart';

class FlipInit {
  final bool flipX;

  final bool flipY;

  FlipInit({
    this.flipX = false,
    this.flipY = false,
  });
}

class FlipComponent extends Component<FlipInit> {
  late bool flipX;

  late bool flipY;

  @override
  void init([FlipInit? initValue]) {
    flipX = initValue?.flipX ?? false;
    flipY = initValue?.flipY ?? false;
  }

  @override
  void reset() {
    flipX = false;
    flipY = false;
  }
}
