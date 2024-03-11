import 'package:flame_devtools/repository.dart';
import 'package:flutter/material.dart';

class ComponentCounter extends StatefulWidget {
  const ComponentCounter({super.key});

  @override
  State<ComponentCounter> createState() => _ComponentCounterState();
}

class _ComponentCounterState extends State<ComponentCounter> {
  Future<int>? _componentCount;

  @override
  void initState() {
    _componentCount = Repository.getComponentCount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _componentCount,
      builder: (context, value) {
        return Column(
          children: [
            Text(
              value.hasData
                  ? '${value.data} Components in the tree'
                  : 'Loading...',
            ),
            ElevatedButton(
              onPressed: () => setState(() {
                _componentCount = Repository.getComponentCount();
              }),
              child: const Text('Update cunt'),
            ),
          ],
        );
      },
    );
  }
}
