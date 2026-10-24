import 'dart:convert';
import 'dart:developer';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/src/devtools/dev_tools_connector.dart';
import 'package:meta/meta.dart';

/// The [HotReloadConnector] supports `flame reload --merge`, a hot reload that
/// keeps the state of the components while it applies the changes that were
/// made to the code that sets them up, such as their constructors and their
/// [Component.onLoad].
///
/// The CLI builds copies of the game, called shadows, before and after the
/// reload, and compares them with each other and with the live game through
/// the Dart VM Service. This connector builds the shadows, reports the
/// structure of the trees, and moves and removes components when the
/// declared children changed.
///
/// The static methods are called by the CLI through expressions that are
/// evaluated in this library, since they take arguments that are objects in
/// the game, which service extensions can't receive.
class HotReloadConnector() extends DevToolsConnector {
  static HotReloadConnector? _instance;

  /// Whether a shadow game is being constructed right now, which is checked
  /// by the constructor of [FlameGame] so that the shadow doesn't replace the
  /// live game in the DevTools.
  static bool get isBuildingShadow => _isBuildingShadow;
  static bool _isBuildingShadow = false;

  final _builds = <String, Future<FlameGame>>{};
  final _shadows = <String, FlameGame>{};
  final _snapshots = <String, List<Component>>{};

  @override
  void init() {
    _instance = this;

    registerExtension(
      'ext.flame_devtools.awaitHotReloadShadow',
      (method, parameters) async {
        final slot = parameters['slot'];
        if (slot == null || !_builds.containsKey(slot)) {
          return ServiceExtensionResponse.error(
            ServiceExtensionResponse.invalidParams,
            'No shadow game is being built for the slot $slot.',
          );
        }
        try {
          return ServiceExtensionResponse.result(
            json.encode(await awaitShadow(slot)),
          );
        } on Object catch (error) {
          return ServiceExtensionResponse.error(
            ServiceExtensionResponse.extensionError,
            'The shadow game could not be built: $error',
          );
        }
      },
    );

    registerExtension(
      'ext.flame_devtools.getHotReloadTree',
      (method, parameters) async {
        return ServiceExtensionResponse.result(json.encode(describeLive()));
      },
    );

    registerExtension(
      'ext.flame_devtools.disposeHotReloadShadows',
      (method, parameters) async {
        disposeShadows();
        return ServiceExtensionResponse.result(json.encode({'ok': true}));
      },
    );
  }

  /// Waits for the shadow game that is being built into [slot], and returns
  /// the description of its tree.
  @internal
  static Future<Map<String, Object?>> awaitShadow(String slot) async {
    final connector = _instance!;
    try {
      final shadow = await connector._builds[slot]!;
      return connector._describe(slot, shadow);
    } finally {
      connector._builds.remove(slot);
    }
  }

  /// Returns the description of the tree of the live game.
  @internal
  static Map<String, Object?> describeLive() {
    final connector = _instance!;
    return connector._describe('live', connector.game);
  }

  /// Removes the components of all the shadow games and forgets them.
  @internal
  static void disposeShadows() => _instance!._disposeShadows();

  @override
  void disposeGame() => _disposeShadows();

  /// Starts to build a shadow game with [create] into [slot], which the
  /// `awaitHotReloadShadow` service extension then waits for.
  @internal
  static void buildShadow(String slot, FlameGame Function() create) {
    final connector = _instance!;
    connector._builds[slot] = connector._build(slot, create)..ignore();
  }

  /// The component at [index] in the last description of the tree in [slot],
  /// which is `live` for the live game.
  @internal
  static Component component(String slot, int index) {
    return _instance!._snapshots[slot]![index];
  }

  /// Moves the component at [newIndex] in the `new` shadow to the component
  /// at [parentIndex] in the live game, since the code declares it now but
  /// the live game doesn't have it yet.
  ///
  /// It is removed from the shadow first, so that it is mounted again in the
  /// live game and registers itself there, for example with the collision
  /// detection.
  @internal
  static void adopt(int newIndex, int parentIndex) {
    final component = HotReloadConnector.component('new', newIndex);
    final parent = HotReloadConnector.component('live', parentIndex);
    final shadow = component.findGame()!;
    for (final c in [component, ...component.descendants()]) {
      if (c is HasGameRef) {
        c.gameRef = null;
      }
      if (c is HasWorldRef) {
        // ignore: invalid_use_of_visible_for_testing_member
        c.worldRef = null;
      }
    }
    component.removeFromParent();
    shadow.processLifecycleEvents();
    parent.add(component);
  }

  /// Removes the component at [liveIndex] from the live game, since the code
  /// doesn't declare it anymore.
  @internal
  static void remove(int liveIndex) {
    HotReloadConnector.component('live', liveIndex).removeFromParent();
  }

  Future<FlameGame> _build(String slot, FlameGame Function() create) async {
    final FlameGame shadow;
    _isBuildingShadow = true;
    try {
      shadow = create();
    } finally {
      _isBuildingShadow = false;
    }
    _shadows[slot] = shadow;
    shadow
      ..markAsHotReloadShadow()
      ..images = game.images
      ..assets = game.assets
      ..onGameResize(game.canvasSize.clone());
    await shadow.load();
    shadow.mount();
    await shadow.ready();
    return shadow;
  }

  /// Lists the components of [root] depth first, which is the order that the
  /// indices of [component] refer to, and remembers them under [slot].
  Map<String, Object?> _describe(String slot, FlameGame root) {
    final components = <Component>[];
    final nodes = <Map<String, Object?>>[];
    void visit(Component component, int? parent) {
      final index = components.length;
      components.add(component);
      nodes.add({
        'parent': parent,
        'declaration_index': component.debugDeclarationIndex,
        'type': component.runtimeType.toString(),
        'key': component.key?.hashCode,
        'identity': identityHashCode(component),
        'hint': switch (component) {
          final PositionComponent c => '${c.position} ${c.size}',
          _ => null,
        },
      });
      for (final child in component.children) {
        visit(child, index);
      }
    }

    visit(root, null);
    _snapshots[slot] = components;
    return {'nodes': nodes};
  }

  void _disposeShadows() {
    for (final shadow in _shadows.values) {
      shadow.removeAll(shadow.children);
      shadow.processLifecycleEvents();
    }
    _shadows.clear();
    _builds.clear();
    _snapshots.clear();
  }
}
