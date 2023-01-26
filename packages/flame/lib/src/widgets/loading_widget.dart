import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

typedef MessageReceiverFunction<M> = void Function(M message);

/// Add this mixin to stateful or stateless widget and run [initMessageListener]
/// to subscribe on loading progress stream.
/// The mixin works with typed messages, so you should to create a class to
/// represent progress message and pass it as template parameter.
mixin LoadingWidgetMixin<M> on Widget {
  final _receiver = _LoadingProgressReceiver<M>();

  /// Should be called at user's widget creation time, for example at
  /// initState
  void initMessageListener(MessageReceiverFunction<M> listener) {
    _receiver.addListener(() {
      listener(_receiver.message!);
    });
    _receiver._initStream();
  }

  Widget gameWidget(BuildContext context) {
    final state = context.findAncestorStateOfType<_LoadingProxyWidgetState>();
    if (state != null) {
      return state.widget.gameWidget;
    }
    throw 'Invalid ancestor of the component';
  }
}

@internal
class LoadingProxyWidget extends StatefulWidget {
  const LoadingProxyWidget({
    super.key,
    required this.gameWidget,
    required this.stream,
    required this.child,
  });

  final Widget gameWidget;
  final Stream<dynamic> stream;
  final LoadingWidgetMixin child;

  @override
  State<LoadingProxyWidget> createState() => _LoadingProxyWidgetState();
}

class _LoadingProxyWidgetState extends State<LoadingProxyWidget> {
  StreamSubscription<dynamic>? streamSubscription;

  @override
  void initState() {
    super.initState();

    widget.child._receiver._initStreamFunction = () {
      streamSubscription = widget.stream.listen(
        widget.child._receiver._onLoadingMessage,
      );
    };
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscription?.cancel();
    streamSubscription = null;
    widget.child._receiver.dispose();
  }

  @override
  LoadingWidgetMixin build(BuildContext context) => widget.child;
}

class _LoadingProgressReceiver<M> extends ChangeNotifier {
  _LoadingProgressReceiver();

  M? message;
  Function? _initStreamFunction;

  // ignore: avoid_dynamic_calls
  void _initStream() => _initStreamFunction?.call();

  void _onLoadingMessage(M message) {
    this.message = message;
    notifyListeners();
  }
}
