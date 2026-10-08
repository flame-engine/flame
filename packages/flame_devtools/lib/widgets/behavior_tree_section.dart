import 'dart:async';

import 'package:flame_devtools/behavior_tree_snapshot.dart';
import 'package:flame_devtools/widgets/behavior_tree_view.dart';
import 'package:flutter/material.dart';

/// How often the behavior tree is refreshed while it is live.
const _refreshInterval = Duration(milliseconds: 500);

/// Shows the behavior tree of a component, and keeps it up to date.
///
/// It shows nothing if the component does not have a behavior tree, so it can
/// be added for any selected component.
class const BehaviorTreeSection({
  required this.id,
  required this.fetch,
  super.key,
}) extends StatefulWidget {
  /// The id of the component.
  final int id;

  /// Gets the behavior tree of the component with the given id, or null if it
  /// does not have one.
  final Future<BehaviorTreeSnapshot?> Function(int id) fetch;

  @override
  State<BehaviorTreeSection> createState() => _BehaviorTreeSectionState();
}

class _BehaviorTreeSectionState() extends State<BehaviorTreeSection> {
  Timer? _timer;
  BehaviorTreeSnapshot? _snapshot;
  var _isLive = true;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refresh();
    _timer = Timer.periodic(_refreshInterval, (_) {
      if (_isLive) {
        _refresh();
      }
    });
  }

  @override
  void didUpdateWidget(BehaviorTreeSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      _snapshot = null;
      _refresh();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    final id = widget.id;
    final snapshot = await widget.fetch(id);
    _isLoading = false;
    if (!mounted) {
      return;
    }
    if (id != widget.id) {
      // The selection changed while the tree was loading, so what was fetched
      // belongs to another component. The refresh that the change asked for
      // was dropped because this one was still running, and nothing else would
      // ask for it when the view is not live, so it is done here.
      await _refresh();
      return;
    }
    setState(() => _snapshot = snapshot);
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    if (snapshot == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    return BehaviorTreeView(
      snapshot: snapshot,
      controls: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Live', style: theme.textTheme.bodyMedium),
          Switch(
            value: _isLive,
            onChanged: (value) {
              setState(() => _isLive = value);
              if (value) {
                _refresh();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            iconSize: 18,
            tooltip: 'Refresh',
            onPressed: _refresh,
          ),
        ],
      ),
    );
  }
}
