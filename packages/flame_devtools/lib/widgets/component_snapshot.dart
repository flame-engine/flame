import 'package:flame/flame.dart';
import 'package:flame/widgets.dart';
import 'package:flame_devtools/repository.dart';
import 'package:flutter/material.dart' hide Image;

class ComponentSnapshot extends StatefulWidget {
  const ComponentSnapshot({
    required this.id,
    super.key,
  });

  final String id;

  @override
  State<ComponentSnapshot> createState() => _ComponentSnapshotState();
}

class _ComponentSnapshotState extends State<ComponentSnapshot> {
  late Future<String?> _snapshot;

  @override
  void initState() {
    super.initState();

    _snapshot = Repository.snapshot(id: widget.id);
  }

  @override
  void didUpdateWidget(ComponentSnapshot oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.id != widget.id) {
      _snapshot = Repository.snapshot(id: widget.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _snapshot,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final imageFuture = Flame.images.fromBase64(
            widget.id,
            snapshot.data!,
          );
          return FutureBuilder(
            future: imageFuture,
            builder: (context, imageSnapshot) {
              if (imageSnapshot.connectionState == ConnectionState.done) {
                return SizedBox(
                  width: 200,
                  height: 200,
                  child: SpriteWidget(
                    sprite: Sprite(
                      imageSnapshot.data!,
                    ),
                  ),
                );
              }
              return const Text('Loading image...');
            },
          );
        }
        return const Text('Loading snapshot...');
      },
    );
  }
}
