import 'package:behavior_tree/behavior_tree.dart';

/// A decorator that swaps the success and failure of its child.
///
/// [Status.running] is passed through unchanged.
class Inverter(super.child) extends Decorator {
  @override
  Status onTick(TickContext context) {
    return switch (child.tick(context)) {
      Status.success => Status.failure,
      Status.failure => Status.success,
      Status.running => Status.running,
    };
  }
}
