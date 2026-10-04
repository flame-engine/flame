import 'package:flame/devtools.dart';
import 'package:flame_devtools/repository.dart';
import 'package:flutter/material.dart';

/// Shows the images held by the game's image cache, how much memory they take
/// and how many times each one is retained, with a button to evict the
/// unused ones.
class const ImageCachePanel({super.key}) extends StatefulWidget {
  @override
  State<ImageCachePanel> createState() => _ImageCachePanelState();
}

class _ImageCachePanelState() extends State<ImageCachePanel> {
  late Future<ImageCacheInfo> _info;

  @override
  void initState() {
    super.initState();
    _info = Repository.getImageCache();
  }

  void _refresh() {
    setState(() {
      _info = Repository.getImageCache();
    });
  }

  Future<void> _evictUnused() async {
    await Repository.evictUnusedImages();
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ImageCacheInfo>(
      future: _info,
      builder: (context, snapshot) {
        final info = snapshot.data;
        final title = info == null
            ? 'Image cache'
            : 'Image cache: ${_formatBytes(info.sizeBytes)}'
                  '${_budgetSuffix(info.maxSizeBytes)} '
                  'in ${info.entries.length} images';
        return ExpansionTile(
          title: Text(title),
          onExpansionChanged: (expanded) {
            if (expanded) {
              _refresh();
            }
          },
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
                TextButton.icon(
                  onPressed: _evictUnused,
                  icon: const Icon(Icons.cleaning_services),
                  label: const Text('Evict unused'),
                ),
              ],
            ),
            if (info != null)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 240),
                child: _ImageCacheTable(entries: info.entries),
              ),
          ],
        );
      },
    );
  }

  String _budgetSuffix(int? maxSizeBytes) {
    return maxSizeBytes == null ? '' : ' of ${_formatBytes(maxSizeBytes)}';
  }
}

class const _ImageCacheTable({required this.entries}) extends StatelessWidget {
  final List<ImageCacheEntry> entries;

  @override
  Widget build(BuildContext context) {
    final sorted = [...entries]
      ..sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes));
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Key')),
          DataColumn(label: Text('Size'), numeric: true),
          DataColumn(label: Text('Retained'), numeric: true),
        ],
        rows: [
          for (final entry in sorted)
            DataRow(
              cells: [
                DataCell(Text(entry.key)),
                DataCell(Text(_formatBytes(entry.sizeBytes))),
                DataCell(Text(entry.retainCount.toString())),
              ],
            ),
        ],
      ),
    );
  }
}

String _formatBytes(int bytes) {
  if (bytes < 1024) {
    return '$bytes B';
  }
  if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
