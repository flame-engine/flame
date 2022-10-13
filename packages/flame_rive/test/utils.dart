import 'dart:io';
import 'dart:typed_data';

ByteData loadFile(String filename) {
  final file = File('./test/$filename');
  return ByteData.sublistView(file.readAsBytesSync());
}
