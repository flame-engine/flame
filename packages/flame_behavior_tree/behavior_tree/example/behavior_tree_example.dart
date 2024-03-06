import 'package:behavior_tree/behavior_tree.dart';

bool isHungry = true;

void main() {
  // Create a sequence of tasks
  final treeRoot = Sequence(
    children: [
      Condition(() => isHungry),
      Task(goToShop),
      Task(buyFood),
      Task(goToHome),
      Task(eatFood),
    ],
  );

  // Tick the tree
  treeRoot.tick();
}

NodeStatus goToShop() {
  // Go to the shop
  return NodeStatus.success;
}

NodeStatus buyFood() {
  // Buy food
  return NodeStatus.success;
}

NodeStatus goToHome() {
  // Go home
  return NodeStatus.success;
}

NodeStatus eatFood() {
  // Eat food
  return NodeStatus.success;
}
