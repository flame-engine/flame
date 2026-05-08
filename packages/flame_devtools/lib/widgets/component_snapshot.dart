import 'dart:convert';
import 'dart:ui' as ui;

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

/// Displays an image decoded from a base64 data string.
///
/// The decoded [ui.Image] is held by this widget and disposed when the widget
/// is removed or when [base64] / [imageId] changes — without going through
/// the global Flame images cache, so the same component id can show
/// different snapshots over time without serving a stale cached frame.
class Base64Image extends StatefulWidget {
  const Base64Image({
    required this.base64,
    required this.imageId,
    super.key,
  });

  final String base64;
  final String imageId;

  @override
  State<Base64Image> createState() => _Base64ImageState();
}

class _Base64ImageState extends State<Base64Image> {
  late Future<ui.Image> _imageFuture;
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _imageFuture = _decode(widget.base64);
  }

  @override
  void didUpdateWidget(Base64Image oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.base64 != widget.base64 ||
        oldWidget.imageId != widget.imageId) {
      _disposeImage();
      _imageFuture = _decode(widget.base64);
    }
  }

  @override
  void dispose() {
    _disposeImage();
    super.dispose();
  }

  Future<ui.Image> _decode(String base64Data) async {
    final commaIndex = base64Data.indexOf(',');
    final payload = commaIndex == -1
        ? base64Data
        : base64Data.substring(commaIndex + 1);
    final bytes = base64.decode(payload);
    final image = await decodeImageFromList(bytes);
    if (mounted) {
      _image = image;
    } else {
      image.dispose();
    }
    return image;
  }

  void _disposeImage() {
    _image?.dispose();
    _image = null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Image>(
      future: _imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return SizedBox(
            width: 200,
            height: 200,
            child: SpriteWidget(
              sprite: Sprite(snapshot.data!),
            ),
          );
        }
        return const Text('Loading image...');
      },
    );
  }
}
