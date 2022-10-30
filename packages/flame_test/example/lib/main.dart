import 'package:flame/extensions.dart';

void main() {}

class MyVectorChanger {
  Vector2 addOne(Vector2 vector) {
    return vector + Vector2.all(1.0);
  }
}

class MyDoubleChanger {
  double addOne(double number) {
    return number + 1.0;
  }
}
