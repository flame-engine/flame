import '../components/component.dart';
import 'max_viewport.dart';
import 'viewfinder.dart';
import 'viewport.dart';

class Camera2 extends Component {
  Camera2({
    Viewport? viewport,
  }) : viewport = viewport ?? MaxViewport(),
      viewfinder = Viewfinder();

  @override
  Future<void> onLoad() async {
    await add(viewport);
    await add(viewfinder);
  }

  final Viewport viewport;
  final Viewfinder viewfinder;
}
