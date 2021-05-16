import 'dart:io';

void main(args) {
  final current = double.parse(args[0].replaceAll('\n', ''));
  final min = double.parse(args[1].replaceAll('\n', ''));

  if (current < min) {
    exit(1);
  } else {
    exit(0);
  }
}
