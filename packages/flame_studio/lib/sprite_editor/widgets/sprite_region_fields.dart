import 'package:flame_studio/component_editor/widgets/property_editors/number_field.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flame_studio/sprite_editor/bloc/sprite_editor_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template sprite_region_fields}
/// Fields to type the exact region of the sprite, in pixels of the image.
/// {@endtemplate}
class const SpriteRegionFields({super.key}) extends StatelessWidget {
  /// {@macro sprite_region_fields}
  this;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SpriteEditorCubit>();
    final sprite = context.select<SpriteEditorCubit, ComponentSprite>(
      (cubit) => cubit.state.sprite,
    );
    final ComponentPosition(:x, :y) = sprite.srcPosition;
    final ComponentSize(:width, :height) = sprite.srcSize;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        spacing: 12,
        children: [
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: NumberField(
                  label: 'X',
                  value: x,
                  onChanged: (x) => cubit.regionChanged(x, y, width, height),
                ),
              ),
              Expanded(
                child: NumberField(
                  label: 'Y',
                  value: y,
                  onChanged: (y) => cubit.regionChanged(x, y, width, height),
                ),
              ),
            ],
          ),
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: NumberField(
                  label: 'Width',
                  value: width,
                  onChanged: (width) =>
                      cubit.regionChanged(x, y, width, height),
                ),
              ),
              Expanded(
                child: NumberField(
                  label: 'Height',
                  value: height,
                  onChanged: (height) =>
                      cubit.regionChanged(x, y, width, height),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
