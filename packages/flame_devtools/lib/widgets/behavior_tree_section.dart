import 'dart:async';

import 'package:flame_devtools/behavior_tree_snapshot.dart';
import 'package:flame_devtools/repository.dart';
import 'package:flame_devtools/widgets/behavior_tree_view.dart';
import 'package:flutter/material.dart';

/// How often the behavior tree is refreshed while it is live.
const _refreshInterval = Duration(milliseconds: 500);

/// Shows the behavior tree of a component, and keeps it up to date.
///
/// It shows nothing if the component does not have a behavior tree, so it can
/// be added for any selected component.
class const BehaviorTreeSection({required this.id, super.key})
    extends StatefulWidget {
  /// The id of the component.
  final int id;

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
    final snapshot = await Repository.getBehaviorTree(id: id);
    _isLoading = false;
    // The selection might have changed while the tree was loading.
    if (mounted && id == widget.id) {
      setState(() => _snapshot = snapshot);
    }
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
