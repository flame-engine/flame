import 'package:flutter/material.dart';

/// {@template property_section}
/// A titled group of property fields in the properties panel.
/// {@endtemplate}
class const PropertySection({
  /// The name of the property.
  required final String title,

  /// The fields that edit the property.
  required final List<Widget> children,
  super.key,
}) extends StatelessWidget {
  /// {@macro property_section}
  this;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          ...children,
        ],
      ),
    );
  }
}
