import 'package:devtools_app_shared/ui.dart' as devtools_ui;
import 'package:flame_devtools/repository.dart';
import 'package:flutter/material.dart';

class OverlayNav extends StatefulWidget {
  const OverlayNav({super.key});

  @override
  State<OverlayNav> createState() => _DebugModeButtonState();
}

class _DebugModeButtonState extends State<OverlayNav> {
  Future<List<String>>? _overlays;

  @override
  void initState() {
    _overlays = Repository.getOverlays();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _overlays,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox();
        }

        return devtools_ui.RoundedOutlinedBorder(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const devtools_ui.AreaPaneHeader(title: Text('Overlays')),
              for (final overlay in snapshot.data!)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.layers, size: 20),
                  title: Text(overlay),
                  onTap: () => Repository.navigateToOverlay(overlay),
                ),
            ],
          ),
        );
      },
    );
  }
}
