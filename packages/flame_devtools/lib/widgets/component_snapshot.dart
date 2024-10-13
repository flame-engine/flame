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
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return Base64Image(
            base64: snapshot.data!,
            imageId: widget.id,
          );
        }
        return const Text('Loading snapshot...');
      },
    );
  }
}

class Base64Image extends StatelessWidget {
  const Base64Image({
    required this.base64,
    required this.imageId,
    super.key,
  });

  final String base64;
  final String imageId;

  @override
  Widget build(BuildContext context) {
    final imageFuture = Flame.images.fromBase64(
      imageId,
      base64,
    );
    return FutureBuilder(
      future: imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return SizedBox(
            width: 200,
            height: 200,
            child: SpriteWidget(
              sprite: Sprite(
                snapshot.data!,
              ),
            ),
          );
        }
        return const Text('Loading image...');
      },
    );
  }
}
