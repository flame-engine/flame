import 'package:flame/extensions.dart';
import 'package:oxygen/oxygen.dart';

class AngleComponent extends Component<double> {
  late double radians;

  double get degrees => radians * radians2Degrees;
  set degrees(double degrees) => radians = degrees * degrees2Radians;

  @override
  void init([double? radians]) => this.radians = radians ?? 0;

  @override
  void reset() => radians = 0;
}
