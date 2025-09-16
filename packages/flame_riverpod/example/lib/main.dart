import 'dart:async';

import 'package:flame/components.dart' hide Timer;
import 'package:flame/game.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final countingStreamProvider = StreamProvider<int>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (inc) => inc);
});

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

final gameInstance = RefExampleGame();
final GlobalKey<RiverpodAwareGameWidgetState> gameWidgetKey =
    GlobalKey<RiverpodAwareGameWidgetState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(child: FlutterCountingComponent()),
          Expanded(
            child: RiverpodAwareGameWidget(
              key: gameWidgetKey,
              game: gameInstance,
            ),
          ),
        ],
      ),
    );
  }
}

class FlutterCountingComponent extends ConsumerWidget {
  const FlutterCountingComponent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textStyle = Theme.of(
      context,
    ).textTheme.headlineSmall?.copyWith(color: Colors.white);

    final stream = ref.watch(countingStreamProvider);
    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          Text('Flutter', style: textStyle),
          stream.when(
            data: (value) => Text('$value', style: textStyle),
            error: (error, stackTrace) => Text('$error', style: textStyle),
            loading: () => Text('Loading...', style: textStyle),
          ),
        ],
      ),
    );
  }
}

class RefExampleGame extends FlameGame with RiverpodGameMixin {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(TextComponent(text: 'Flame'));
    add(RiverpodAwareTextComponent());
  }
}

class RiverpodAwareTextComponent extends PositionComponent
    with RiverpodComponentMixin {
  late TextComponent textComponent;
  int currentValue = 0;

  /// [onMount] should be used over [onLoad] to initialize subscriptions,
  /// which is only called if the [Component] was mounted.
  /// Cancellation is handled for the user automatically inside [onRemove].
  ///
  /// [RiverpodComponentMixin.addToGameWidgetBuild] **must** be invoked in
  /// your Component **before** [RiverpodComponentMixin.onMount] in order to
  /// have the provided function invoked on
  /// [RiverpodAwareGameWidgetState.build].
  ///
  /// From `flame_riverpod` 5.0.0, [WidgetRef.watch], is also accessible from
  /// components.
  @override
  void onMount() {
    addToGameWidgetBuild(() {
      ref.listen(countingStreamProvider, (p0, p1) {
        if (p1.hasValue) {
          currentValue = p1.value!;
          textComponent.text = '$currentValue';
        }
      });
    });
    super.onMount();
    add(textComponent = TextComponent(position: position + Vector2(0, 27)));
  }
}
