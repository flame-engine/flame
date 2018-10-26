
import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/components/resizable.dart';
import 'package:ordered_set/comparing.dart';
import 'package:ordered_set/ordered_set.dart';


typedef IterateOverComponents = void Function(Component component);

abstract class ComposedComponent extends Component {
  OrderedSet<Component> components = new OrderedSet(Comparing.on((c) => c.priority()));

  @override
  render(Canvas canvas) {
    canvas.save();
    components.forEach((comp) => renderComponent(canvas, comp));
    canvas.restore();
  }

  void renderComponent(Canvas canvas, Component c) {
    c.render(canvas);
    canvas.restore();
    canvas.save();
  }

  @override
  void update(double t) {
    components.forEach((c) => c.update(t));
    components.removeWhere((c) => c.destroy());
  }

  void add(Component c) {
    this.components.add(c);

    if(this is Resizable){
      // first time resize
      Resizable thisResizable = this as Resizable;
      if (thisResizable.size != null) {
        c.resize(thisResizable.size);
      }
    }
  }

  void iterateOverComponents ( IterateOverComponents iterateOverComponentsCallback ){
    components.forEach(iterateOverComponentsCallback);
  }

  @override
  void resize(Size size) {
    if(this is Resizable){
      Resizable thisResizable = this as Resizable;
      thisResizable.size = size;
      components.forEach((c) => c.resize(size));
    }
  }

}