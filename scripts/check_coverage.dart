import 'dart:io';

void main(args) {
  final coverageSummary = args[0] as String;
  final currentRaw = coverageSummary.replaceFirstMapped(
    RegExp(r".* (\d+\.\d+)%.*"),
    (matches) => '${matches[1]}',
  );

  final current = double.parse(currentRaw);
  final min = double.parse(args[1].replaceAll('\n', ''));

  if (current < min) {
    exit(1);
  } else {
    exit(0);
  }
}
