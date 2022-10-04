import 'dart:io';

File fixture(String name) {
  var dir = Directory.current.path;
  if (dir.endsWith('/test')) {
    dir = dir.replaceAll('/test', '');
  }
  return File('$dir/test/_resources/$name');
}

String fixtureForString(String name) =>
    File('test/fixtures/$name').readAsStringSync();
