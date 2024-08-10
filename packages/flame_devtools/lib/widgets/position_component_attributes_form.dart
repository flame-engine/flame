import 'package:flame_devtools/repository.dart';
import 'package:flame_devtools/widgets/incremental_number_form_field.dart';
import 'package:flutter/material.dart';

class PositionComponentAttributesForm extends StatefulWidget {
  const PositionComponentAttributesForm({
    required this.componentId,
    super.key,
  });

  final int componentId;

  @override
  State<PositionComponentAttributesForm> createState() =>
      _PositionComponentAttributesFormState();
}

class _PositionComponentAttributesFormState
    extends State<PositionComponentAttributesForm> {
  late Future<PositionComponentAttributes> _attributesFuture;

  @override
  void initState() {
    super.initState();

    _attributesFuture = Repository.getPositionComponentAttributes(
      id: widget.componentId,
    );
  }

  @override
  void didUpdateWidget(PositionComponentAttributesForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.componentId != widget.componentId) {
      _attributesFuture = Repository.getPositionComponentAttributes(
        id: widget.componentId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PositionComponentAttributes>(
      future: _attributesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final data = snapshot.data!;
          return Column(
            children: [
              Row(
                children: [
                  IncrementalNumberFormField<double>(
                    label: 'X',
                    initialValue: data.x,
                    onChanged: (v) {
                      Repository.setPositionComponentAttribute(
                        id: widget.componentId,
                        attribute: 'x',
                        value: v,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  IncrementalNumberFormField<double>(
                    label: 'Y',
                    initialValue: data.y,
                    onChanged: (v) {
                      Repository.setPositionComponentAttribute(
                        id: widget.componentId,
                        attribute: 'y',
                        value: v,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IncrementalNumberFormField<double>(
                    label: 'Width',
                    initialValue: data.width,
                    onChanged: (v) {
                      Repository.setPositionComponentAttribute(
                        id: widget.componentId,
                        attribute: 'width',
                        value: v,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  IncrementalNumberFormField<double>(
                    label: 'Height',
                    initialValue: data.height,
                    onChanged: (v) {
                      Repository.setPositionComponentAttribute(
                        id: widget.componentId,
                        attribute: 'height',
                        value: v,
                      );
                    },
                  ),
                ],
              ),
            ],
          );
        }
        return const Text('Loading attributes...');
      },
    );
  }
}
