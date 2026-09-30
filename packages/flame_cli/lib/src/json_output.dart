import 'dart:convert';

const _encoder = JsonEncoder.withIndent('  ');

/// Encodes [value] as indented JSON, for the `--json` output of the commands.
String toJsonOutput(Object? value) => _encoder.convert(value);
