import 'package:devtools_app_shared/ui.dart' as devtools_ui;
import 'package:flame_devtools/repository.dart';
import 'package:flutter/material.dart';

class OverlayNavigation extends StatefulWidget {
  const OverlayNavigation({super.key});

  @override
  State<OverlayNavigation> createState() => _OverlayNavigationState();
}

class _OverlayNavigationState extends State<OverlayNavigation> {
  late Future<Overlays> _overlays;

  @override
  void initState() {
    super.initState();
    _overlays = Repository.getOverlays();
  }

  void _refresh() {
    setState(() {
      _overlays = Repository.getOverlays();
    });
  }

  Future<void> _navigateTo(String overlay) async {
    await Repository.navigateToOverlay(overlay);
    _refresh();
  }

  Future<void> _setActive(String overlay, {required bool active}) async {
    await Repository.setOverlay(overlay, active: active);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<Overlays>(
      future: _overlays,
      builder: (context, snapshot) {
        final overlays = snapshot.data;
        if (overlays == null || overlays.registered.isEmpty) {
          return const SizedBox();
        }

        return devtools_ui.RoundedOutlinedBorder(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              devtools_ui.AreaPaneHeader(
                title: Row(
                  children: [
                    Text('Overlays', style: theme.textTheme.titleSmall),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      iconSize: 18,
                      alignment: Alignment.center,
                      onPressed: _refresh,
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 240),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final overlay in overlays.registered)
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.layers, size: 20),
                        title: Text(overlay),
                        subtitle: const Text('Tap to show only this overlay'),
                        trailing: Switch(
                          value: overlays.active.contains(overlay),
                          onChanged: (active) =>
                              _setActive(overlay, active: active),
                        ),
                        onTap: () => _navigateTo(overlay),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
