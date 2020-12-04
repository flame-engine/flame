import '../component.dart';

mixin HasAsyncLoading on Component {
  Future<void> onLoad();
}
