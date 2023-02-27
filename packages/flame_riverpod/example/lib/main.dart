import 'dart:async';

import 'package:flame/components.dart' hide Timer;
import 'package:flame/game.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final countingStreamProvider = StreamProvider<int>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (inc) => inc);
});

/// Simple provider that returns a [FlameGame] instance.
final riverpodAwareGameProvider =
    StateNotifierProvider<RiverpodAwareGameNotifier, FlameGame?>((ref) {
  return RiverpodAwareGameNotifier();
});

/// Simple [StateNotifier] that holds the current [FlameGame] instance.
class RiverpodAwareGameNotifier extends StateNotifier<FlameGame?> {
  RiverpodAwareGameNotifier() : super(null);

  void set(FlameGame candidate) {
    state = candidate;
  }
}

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Expanded(child: FlutterCountingComponent()),
          Expanded(
            child: RiverpodGameWidget.initializeWithGame(
              uninitializedGame: RefExampleGame.new,
            ),
          )
        ],
      ),
    );
  }
}

class FlutterCountingComponent extends ConsumerWidget {
  const FlutterCountingComponent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textStyle = Theme.of(context)
        .textTheme
        .headlineSmall
        ?.copyWith(color: Colors.white);

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
          )
        ],
      ),
    );
  }
}

class RefExampleGame extends FlameGame with HasComponentRef {
  RefExampleGame(WidgetRef ref) {
    // Note: WidgetRef is not stored and is used to build a [ComponentRef],
    // a wrapper around it.
    HasComponentRef.widgetRef = ref;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(TextComponent(text: 'Flame'));
    add(RiverpodAwareTextComponent());
  }
}

class RiverpodGameWidget extends ConsumerStatefulWidget {
  const RiverpodGameWidget.readFromProvider({super.key})
      : uninitializedGame = null;
  const RiverpodGameWidget.initializeWithGame({
    super.key,
    required this.uninitializedGame,
  });

  final FlameGame Function(WidgetRef ref)? uninitializedGame;

  @override
  ConsumerState<RiverpodGameWidget> createState() => _RiverpodGameWidgetState();
}

class _RiverpodGameWidgetState extends ConsumerState<RiverpodGameWidget> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.uninitializedGame is FlameGame Function(WidgetRef ref)) {
        ref
            .read(riverpodAwareGameProvider.notifier)
            .set(widget.uninitializedGame!(ref));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(riverpodAwareGameProvider);

    if (game is! Game) {
      return Container();
    }

    return GameWidget(game: game!);
  }
}

class RiverpodAwareTextComponent extends PositionComponent
    with HasComponentRef {
  late TextComponent textComponent;
  int currentValue = 0;

  /// [onMount] should be used over [onLoad] to initialize subscriptions,
  /// cancellation is handled for the user inside [onRemove],
  /// which is only called if the [Component] was mounted.
  @override
  void onMount() {
    super.onMount();
    add(textComponent = TextComponent(position: position + Vector2(0, 27)));

    // "Watch" a provider using [listen] from the [HasComponentRef] mixin.
    // Watch is not exposed directly as this would rebuild the ancestor that
    // exposes the [WidgetRef] unnecessarily.
    listen(countingStreamProvider, (p0, p1) {
      if (p1.hasValue) {
        currentValue = p1.value!;
        textComponent.text = '$currentValue';
      }
    });
  }
}
