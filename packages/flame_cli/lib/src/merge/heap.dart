import 'package:flame_cli/src/flame_cli_exception.dart';
import 'package:flame_cli/src/merge/merge.dart';
import 'package:flame_cli/src/merge/tree_match.dart';
import 'package:io/io.dart';
import 'package:vm_service/vm_service.dart' hide Error;

const _connectorLibrary =
    'package:flame/src/devtools/connectors/hot_reload_connector.dart';

const _componentLibrary = 'package:flame/src/components/core/component.dart';

/// The fields of `Component` that are compared, all the others are the
/// lifecycle and the structure of the tree, which is merged separately.
const _comparedComponentFields = {'_priority', 'debugMode'};

/// The fields that are never compared, since they are derived from other
/// fields.
const _excludedFields = {
  'package:flame/src/game/transform2d.dart#Transform2D._transformMatrix',
  'package:flame/src/game/transform2d.dart#Transform2D._recalculate',
  'package:flame/src/game/transform2d.dart#Transform2D._recalculateRotation',
  'package:flame/src/game/transform2d.dart#Transform2D._cosAngle',
  'package:flame/src/game/transform2d.dart#Transform2D._sinAngle',
};

/// The classes of Flame whose fields are the internals of the game loop and
/// the lifecycle, which the code of a game doesn't declare.
const _excludedOwners = {'Game', 'FlameGame', 'ComponentTreeRoot'};

/// The classes of `dart:ui` that are plain values, all other classes of that
/// library are compared by their identity.
const _uiValueClasses = {
  'Color',
  'Offset',
  'Size',
  'Rect',
  'RRect',
  'Radius',
  'Paint',
};

const _typedDataKinds = {
  InstanceKind.kUint8ClampedList,
  InstanceKind.kUint8List,
  InstanceKind.kUint16List,
  InstanceKind.kUint32List,
  InstanceKind.kUint64List,
  InstanceKind.kInt8List,
  InstanceKind.kInt16List,
  InstanceKind.kInt32List,
  InstanceKind.kInt64List,
  InstanceKind.kFloat32List,
  InstanceKind.kFloat64List,
  InstanceKind.kInt32x4List,
  InstanceKind.kFloat32x4List,
  InstanceKind.kFloat64x2List,
};

const _primitiveKinds = {
  InstanceKind.kNull,
  InstanceKind.kBool,
  InstanceKind.kInt,
  InstanceKind.kDouble,
  InstanceKind.kString,
};

/// The name of [slot] in the `HotReloadConnector` of the game.
String _slotName(Slot slot) => slot == Slot.updated ? 'new' : slot.name;

/// Reads and changes the objects of the game through the Dart VM Service, for
/// a merging reload.
class Heap._(
  final VmService _service,
  final String _isolateId,
  final String _connectorLibraryId,
) {
  /// How deep objects are followed from a component.
  static const maxDepth = 8;

  /// How many elements of a collection are compared.
  static const maxElements = 64;

  static Future<Heap> connect(VmService service, String isolateId) async {
    final isolate = await service.getIsolate(isolateId);
    final library = isolate.libraries
        ?.where((library) => library.uri == _connectorLibrary)
        .firstOrNull;
    if (library == null) {
      throw const FlameCliException(
        'The running game does not support merging reloads, update Flame to '
        'the latest version.',
        exitCode: ExitCode.unavailable,
      );
    }
    return Heap._(service, isolateId, library.id!);
  }

  /// Evaluates [expression] in the library [libraryId], and returns the
  /// resulting object, or null when it didn't compile or threw.
  Future<InstanceRef?> _evaluate(
    String libraryId,
    String expression, {
    Map<String, String>? scope,
  }) async {
    try {
      final result = await _service.evaluate(
        _isolateId,
        libraryId,
        expression,
        scope: scope,
        disableBreakpoints: true,
      );
      return result is InstanceRef ? result : null;
    } on RPCError {
      return null;
    } on SentinelException {
      return null;
    }
  }

  Future<InstanceRef> _evaluateInConnector(
    String expression, {
    Map<String, String>? scope,
  }) async {
    final result = await _evaluate(
      _connectorLibraryId,
      expression,
      scope: scope,
    );
    if (result == null) {
      throw FlameCliException(
        'The game could not evaluate `$expression`.',
      );
    }
    return result;
  }

  /// The component [id] in the last description of the tree [slot].
  Future<String> component(Slot slot, int id) async {
    final result = await _evaluateInConnector(
      "HotReloadConnector.component('${_slotName(slot)}', $id)",
    );
    return result.id!;
  }

  /// Starts to build a shadow of the live game into [slot], with the
  /// constructor of its class that takes no arguments.
  ///
  /// The live tree has to have been described before, since the class is
  /// looked up on its root.
  Future<void> buildShadow(Slot slot) async {
    final game = await _evaluateInConnector(
      "HotReloadConnector.component('live', 0)",
    );
    final gameClass = game.classRef!;
    final factory = await _evaluate(
      gameClass.library!.id!,
      '() => ${gameClass.name}()',
    );
    if (factory == null) {
      throw FlameCliException(
        'A merging reload builds copies of the game with '
        '`${gameClass.name}()`, which does not compile. Give the game a '
        'constructor that takes no arguments, or use `flame reload` without '
        '--merge.',
      );
    }
    await _evaluateInConnector(
      "HotReloadConnector.buildShadow('${_slotName(slot)}', factory)",
      scope: {'factory': factory.id!},
    );
  }

  Future<void> adopt(int newId, int liveParent) async {
    await _evaluateInConnector('HotReloadConnector.adopt($newId, $liveParent)');
  }

  Future<void> remove(int liveId) async {
    await _evaluateInConnector('HotReloadConnector.remove($liveId)');
  }

  Future<void> setDeclarationIndex(int liveId, int declarationIndex) async {
    await _evaluateInConnector(
      "HotReloadConnector.component('live', $liveId).debugDeclarationIndex = "
      '$declarationIndex',
    );
  }

  /// Reads the leaves of the component [id] in [tree], which is in [slot].
  Future<Leaves> read(Slot slot, int id, ComponentTree tree) async {
    final leaves = <String, Leaf>{};
    final visited = <int>{};

    void add(List<PathSegment> path, String value) {
      final leaf = Leaf(path, value);
      leaves[leaf.key] = leaf;
    }

    Future<void> visit(Object? value, List<PathSegment> path) async {
      if (value is! InstanceRef) {
        return;
      }
      final kind = value.kind;
      if (_primitiveKinds.contains(kind)) {
        add(path, await _primitive(value));
        return;
      }
      if (kind == InstanceKind.kClosure) {
        return;
      }
      final identity = value.identityHashCode;
      final componentId = identity == null ? null : tree.idOf(identity);
      if (componentId != null && path.isNotEmpty) {
        add(path, 'component:$componentId');
        return;
      }
      // The identity hash code is 0 for objects that never needed one, so
      // it can't tell those apart.
      if (identity != null && identity != 0 && !visited.add(identity)) {
        add(path, 'seen');
        return;
      }
      if (path.length > maxDepth) {
        add(path, 'depth');
        return;
      }

      if (_typedDataKinds.contains(kind)) {
        final instance = await _instance(value.id!);
        add(path, 'bytes:${instance.bytes}');
        return;
      }
      if (kind == InstanceKind.kList || kind == InstanceKind.kSet) {
        final instance = await _instance(value.id!, count: maxElements);
        add(path, 'length:${instance.length}');
        final elements = instance.elements ?? const [];
        await Future.wait([
          for (final (index, element) in elements.indexed)
            visit(element, [...path, IndexSegment(index)]),
        ]);
        return;
      }
      if (kind == InstanceKind.kMap) {
        final instance = await _instance(value.id!, count: maxElements);
        add(path, 'length:${instance.length}');
        final associations = instance.associations ?? const <MapAssociation>[];
        await Future.wait([
          for (final association in associations)
            if (_primitiveKey(association) case final key?)
              _primitive(key).then(
                (key) => visit(association.value, [...path, EntrySegment(key)]),
              ),
        ]);
        return;
      }

      final classRef = value.classRef;
      final libraryUri = classRef?.library?.uri ?? '';
      if (path.isNotEmpty) {
        add(path, 'type:$libraryUri#${classRef?.name}');
      }
      if (kind != InstanceKind.kPlainInstance ||
          !_isComparedByValue(libraryUri, classRef?.name)) {
        add(path, 'identity:${await _identity(value)}');
        return;
      }

      final instance = await _instance(value.id!);
      await Future.wait([
        for (final field in instance.fields ?? const <BoundField>[])
          if (_segment(field) case final segment? when !_isExcluded(segment))
            visit(field.value, [...path, segment]),
      ]);
    }

    await visit(
      InstanceRef(
        kind: InstanceKind.kPlainInstance,
        id: await component(slot, id),
      ),
      [],
    );
    return leaves;
  }

  /// Writes the object [sourceId] to the field at the end of [path] in the
  /// object that [objectId] refers to, or the same field of [sourceId] when
  /// [copyField] is true.
  ///
  /// The field is written in the first of these ways that works: through a
  /// public setter with the name of a private field, in place with `setFrom`,
  /// in place by replacing the elements of a collection, and lastly by
  /// assigning the field.
  Future<bool> write(
    String objectId,
    List<PathSegment> path,
    String sourceId, {
    required bool copyField,
  }) async {
    final field = path.last as FieldSegment;
    final target = await _resolve(objectId, path.sublist(0, path.length - 1));
    if (target == null) {
      return false;
    }
    final name = field.name;
    final public = name.startsWith('_') ? name.substring(1) : null;
    final expressions = copyField
        ? [
            if (public != null) 'target.$public = other.$public',
            'target.$name.setFrom(other.$name)',
            'target.$name..clear()..addAll(other.$name)',
            'target.$name = other.$name',
          ]
        : [
            if (public != null) 'target.$public = other',
            'target.$name = other',
          ];
    for (final expression in expressions) {
      final result = await _evaluate(
        field.libraryId,
        expression,
        scope: {'target': target, 'other': sourceId},
      );
      if (result != null) {
        return true;
      }
    }
    return false;
  }

  /// Follows [path] from the object [objectId], and returns the id of the
  /// object at its end.
  Future<String?> resolve(String objectId, List<PathSegment> path) {
    return _resolve(objectId, path);
  }

  Future<String?> _resolve(String objectId, List<PathSegment> path) async {
    var current = objectId;
    for (final segment in path) {
      final Object? next;
      switch (segment) {
        case FieldSegment():
          final instance = await _instance(current);
          next = instance.fields
              ?.where((field) => _segment(field)?.key == segment.key)
              .firstOrNull
              ?.value;
        case IndexSegment(:final index):
          final instance = await _instance(current, offset: index, count: 1);
          next = instance.elements?.firstOrNull;
        case EntrySegment(:final entryKey):
          final instance = await _instance(current);
          Object? found;
          for (final association
              in instance.associations ?? const <MapAssociation>[]) {
            if (_primitiveKey(association) case final key?
                when await _primitive(key) == entryKey) {
              found = association.value;
              break;
            }
          }
          next = found;
      }
      if (next is! InstanceRef || next.id == null) {
        return null;
      }
      current = next.id!;
    }
    return current;
  }

  Future<Instance> _instance(String id, {int? offset, int? count}) async {
    final object = await _service.getObject(
      _isolateId,
      id,
      offset: offset,
      count: count,
    );
    return object as Instance;
  }

  Future<String> _primitive(InstanceRef value) async {
    var text = value.valueAsString;
    if (value.kind == InstanceKind.kString &&
        (value.valueAsStringIsTruncated ?? false)) {
      final instance = await _instance(value.id!, count: value.length);
      text = instance.valueAsString;
    }
    return '${value.kind}:$text';
  }

  static InstanceRef? _primitiveKey(MapAssociation association) {
    final Object? key = association.key;
    return key is InstanceRef && _primitiveKinds.contains(key.kind)
        ? key
        : null;
  }

  static FieldSegment? _segment(BoundField field) {
    final declaration = field.decl;
    final owner = declaration?.owner;
    if (declaration == null || owner is! ClassRef || owner.library == null) {
      return null;
    }
    return FieldSegment(
      libraryUri: owner.library!.uri!,
      libraryId: owner.library!.id!,
      className: owner.name!,
      name: declaration.name!,
    );
  }

  /// The identity hash code of [value], which is computed in the game when
  /// the object didn't have one yet.
  Future<int?> _identity(InstanceRef value) async {
    final identity = value.identityHashCode;
    if (identity != 0 || value.id == null) {
      return identity;
    }
    final result = await _evaluate(
      _connectorLibraryId,
      'identityHashCode(object)',
      scope: {'object': value.id!},
    );
    return int.tryParse(result?.valueAsString ?? '');
  }

  static bool _isExcluded(FieldSegment segment) {
    if (segment.libraryUri == _componentLibrary &&
        segment.className == 'Component') {
      return !_comparedComponentFields.contains(segment.name);
    }
    if (_excludedFields.contains(segment.key) ||
        segment.libraryUri.startsWith('package:flutter/')) {
      return true;
    }
    return segment.libraryUri.startsWith('package:flame/') &&
        _excludedOwners.contains(segment.className);
  }

  static bool _isComparedByValue(String libraryUri, String? className) {
    if (libraryUri == 'dart:ui') {
      return _uiValueClasses.contains(className);
    }
    return !libraryUri.startsWith('package:flutter/') &&
        !const {
          'dart:async',
          'dart:isolate',
          'dart:developer',
          'dart:io',
        }.contains(libraryUri);
  }
}

/// A [MergeWriter] that changes the live game through a [Heap].
class HeapMergeWriter(final Heap heap) implements MergeWriter {
  @override
  Future<bool> write(
    Slot slot,
    int id,
    List<PathSegment> path,
    WriteSource source,
  ) async {
    final target = await heap.component(slot, id);
    switch (source) {
      case CopyFrom(:final newId):
        final other = await heap.resolve(
          await heap.component(Slot.updated, newId),
          path.sublist(0, path.length - 1),
        );
        if (other == null) {
          return false;
        }
        return await heap.write(target, path, other, copyField: true);
      case ComponentValue(slot: final valueSlot, id: final valueId):
        final value = await heap.component(valueSlot, valueId);
        return await heap.write(target, path, value, copyField: false);
    }
  }

  @override
  Future<void> adopt(int newId, int liveParent) =>
      heap.adopt(newId, liveParent);

  @override
  Future<void> remove(int liveId) => heap.remove(liveId);

  @override
  Future<void> setDeclarationIndex(int liveId, int declarationIndex) {
    return heap.setDeclarationIndex(liveId, declarationIndex);
  }
}
