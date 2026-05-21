import 'dart:convert';
import 'dart:io';

/// Build each shader in [names] to a `.wgslbundle` asset in [assets].
///
/// Each name must have a matching `.vert` and `.frag` in [shaders]. Stale
/// `.wgslbundle` files are removed first and other assets are left untouched.
///
/// Requires `naga` (`cargo install naga-cli`) on PATH.
void build(
  Iterable<String> names,
  Directory shaders,
  Directory assets,
  List<Directory> packageShaderDirs,
) {
  for (final file in assets.listSync().whereType<File>()) {
    if (file.path.endsWith('.wgslbundle')) {
      file.deleteSync();
    }
  }

  final includeDirs = [shaders, ...packageShaderDirs];
  final tmp = Directory.systemTemp.createTempSync('flame3d_web_shaders');
  const encoder = JsonEncoder.withIndent('  ');
  try {
    for (final name in names) {
      stdout.writeln('Computing web shader bundle "$name"');
      final vertex = _compileStage(shaders, tmp, name, 'vert', includeDirs);
      final fragment = _compileStage(shaders, tmp, name, 'frag', includeDirs);
      final bundle = {
        'vertex': vertex,
        'fragment': fragment,
        'slots': {..._reflect(vertex), ..._reflect(fragment)},
      };
      File.fromUri(
        assets.uri.resolve('$name.wgslbundle'),
      ).writeAsStringSync('${encoder.convert(bundle)}\n');
    }
  } finally {
    tmp.deleteSync(recursive: true);
  }
}

/// Preprocesses and compiles one GLSL [stage] of [name] to WGSL with `naga`.
String _compileStage(
  Directory shaders,
  Directory tmp,
  String name,
  String stage,
  List<Directory> includeDirs,
) {
  final source = File('${shaders.path}/$name.$stage').readAsStringSync();
  final resolved = _resolveIncludes(source, includeDirs);
  _checkUniformArrays(resolved, '$name.$stage');

  final glsl = File('${tmp.path}/$name.$stage.glsl')
    ..writeAsStringSync(_preprocess(resolved, stage));
  final wgsl = File('${tmp.path}/$name.$stage.wgsl');

  final result = Process.runSync('naga', [glsl.path, wgsl.path]);
  if (result.exitCode != 0) {
    stderr
      ..writeln('naga ${[glsl.path, wgsl.path].join(' ')} failed:')
      ..writeln(result.stdout)
      ..writeln(result.stderr);
    throw ProcessException('naga', [
      glsl.path,
      wgsl.path,
    ], 'exited ${result.exitCode}');
  }

  return wgsl.readAsStringSync();
}

String _resolveIncludes(
  String source,
  List<Directory> includeDirs, [
  Set<String>? seen,
]) {
  final included = seen ?? <String>{};
  final directive = RegExp(
    r'^[ \t]*#include[ \t]+[<"]([^>"]+)[>"][ \t]*$',
    multiLine: true,
  );
  return source.replaceAllMapped(directive, (match) {
    final path = match.group(1)!;
    for (final dir in includeDirs) {
      final file = File('${dir.path}/$path');
      if (!file.existsSync()) {
        continue;
      }

      if (!included.add(file.absolute.path)) {
        return ''; // already inlined for this shader
      }

      return _resolveIncludes(file.readAsStringSync(), includeDirs, included);
    }

    throw StateError(
      'Cannot resolve #include "$path", searched: '
      '${includeDirs.map((d) => d.path).join(', ')}',
    );
  });
}

/// Fails fast on uniform-block array members WGSL can't represent.
///
/// A WGSL uniform block requires every array element on a stride that is a
/// multiple of 16 bytes, so a `float[]` or `vec2[]` member is rejected
void _checkUniformArrays(String glsl, String label) {
  final block = RegExp(r'uniform\s+\w+\s*\{([^}]*)\}');
  final badMember = RegExp(r'\b(float|vec2)\s+(\w+)\s*\[');
  for (final match in block.allMatches(glsl)) {
    final member = badMember.firstMatch(match.group(1)!);
    if (member != null) {
      throw StateError(
        'Shader "$label": uniform-block array "${member.group(2)}" has '
        '${member.group(1)} elements, WGSL needs a 16-byte array stride. '
        'Declare it as a vec4 array.',
      );
    }
  }
}

String _preprocess(String glsl, String stage) {
  final set = stage == 'vert' ? 0 : 1;
  var inLocation = 0;
  var outLocation = 0;
  var binding = 0;
  final samplers = <String>[];
  final out = StringBuffer();

  final varying = RegExp(r'^(\s*)((?:smooth\s+)?(?:in|out)\s+\w+\s+\w+;)');
  final sampler = RegExp(r'^(\s*)uniform\s+sampler2D\s+(\w+);');
  final block = RegExp(r'^(\s*)uniform\s+\w+\s*\{');

  for (final line in const LineSplitter().convert(glsl)) {
    final samplerMatch = sampler.firstMatch(line);
    if (samplerMatch != null) {
      final indent = samplerMatch.group(1)!;
      final name = samplerMatch.group(2)!;
      out.writeln(
        '${indent}layout(set = $set, binding = ${binding++}) '
        'uniform texture2D $name;',
      );
      out.writeln(
        '${indent}layout(set = $set, binding = ${binding++}) '
        'uniform sampler ${name}Sampler;',
      );
      samplers.add(name);
      continue;
    }

    final blockMatch = block.firstMatch(line);
    if (blockMatch != null) {
      final indent = blockMatch.group(1)!;
      out.writeln(
        line.replaceFirst(
          '${indent}uniform',
          '${indent}layout(set = $set, binding = ${binding++}) uniform',
        ),
      );
      continue;
    }

    final varyingMatch = varying.firstMatch(line);
    if (varyingMatch != null) {
      final indent = varyingMatch.group(1)!;
      final decl = varyingMatch.group(2)!;
      final location = decl.contains(RegExp(r'\bin\b'))
          ? inLocation++
          : outLocation++;
      out.writeln('${indent}layout(location = $location) $decl');
      continue;
    }

    out.writeln(line);
  }

  var result = out.toString();
  for (final name in samplers) {
    result = result.replaceAll(
      'texture($name,',
      'texture(sampler2D($name, ${name}Sampler),',
    );
  }

  if (stage == 'vert') {
    // `vector_math`'s perspective matrix is GL-style so it outputs clip-space
    // z in [-1, 1]. WebGPU (like Vulkan/Metal) expects [0, 1] and clips
    // z < 0. Remap it after `main` has finished writing `gl_Position`.
    final close = result.lastIndexOf('}');
    result =
        '${result.substring(0, close)}'
        '  gl_Position.z = (gl_Position.z + gl_Position.w) * 0.5;\n'
        '${result.substring(close)}';
  }
  return result;
}

/// Derives the uniform-block and texture slots of a compiled WGSL [stage].
Map<String, dynamic> _reflect(String stage) {
  final structs = _parseStructs(stage);
  final slots = <String, dynamic>{};

  // `@group(N) @binding(M) var[<uniform>] name: type;`
  final bindings = RegExp(
    r'@group\((\d+)\)\s*@binding\((\d+)\)\s*'
    r'var(?:<uniform>)?\s+(\w+)\s*:\s*([^;]+);',
  );

  final samplers = <String, int>{};
  final textures = <(String name, int group, int binding)>[];

  for (final match in bindings.allMatches(stage)) {
    final group = int.parse(match.group(1)!);
    final binding = int.parse(match.group(2)!);
    final name = match.group(3)!;
    final type = match.group(4)!.trim();

    if (type == 'sampler') {
      samplers[name] = binding;
    } else if (type.startsWith('texture')) {
      textures.add((name, group, binding));
    } else {
      final layout = _structLayout(structs[type]!, structs);
      slots[type] = {
        'group': group,
        'binding': binding,
        'sizeInBytes': layout.size,
        'memberOffsets': layout.offsets,
      };
    }
  }

  for (final (name, group, binding) in textures) {
    slots[name] = {
      'group': group,
      'binding': binding,
      if (samplers['${name}Sampler'] case final sampler?)
        'samplerBinding': sampler,
    };
  }
  return slots;
}

/// Parses every `struct Name { ... }` declaration, keyed by name. Each value
/// is the struct's members as ordered `(name, type)` pairs.
Map<String, List<(String, String)>> _parseStructs(String wgsl) {
  final structs = <String, List<(String, String)>>{};
  final declaration = RegExp(r'struct\s+(\w+)\s*\{([^}]*)\}');
  // naga emits one member per line: `  name: type,` (a `@location(N)` prefix
  // appears on stage-IO structs, which are never laid out).
  final member = RegExp(r'^\s*(?:@\w+\([^)]*\)\s*)?(\w+)\s*:\s*(.+),\s*$');

  for (final match in declaration.allMatches(wgsl)) {
    structs[match.group(1)!] = [
      for (final line in const LineSplitter().convert(match.group(2)!))
        if (member.firstMatch(line) case final field?)
          (field.group(1)!, field.group(2)!.trim()),
    ];
  }

  return structs;
}

/// Computes the byte offset of each member and the padded total size of a
/// struct, per the WGSL uniform address space layout rules.
({int size, int align, Map<String, int> offsets}) _structLayout(
  List<(String, String)> fields,
  Map<String, List<(String, String)>> structs,
) {
  var offset = 0;
  var align = 0;
  final offsets = <String, int>{};
  for (final (name, type) in fields) {
    final (size: size, align: fieldAlign) = _sizeAlign(type, structs);
    offset = _roundUp(offset, fieldAlign);
    offsets[name] = offset;
    offset += size;
    align = fieldAlign > align ? fieldAlign : align;
  }
  return (size: _roundUp(offset, align), align: align, offsets: offsets);
}

/// The size and alignment, in bytes, of a WGSL [type] under uniform layout.
({int size, int align}) _sizeAlign(
  String type,
  Map<String, List<(String, String)>> structs,
) {
  switch (type) {
    case 'f32' || 'i32' || 'u32':
      return (size: 4, align: 4);
    case 'vec2<f32>':
      return (size: 8, align: 8);
    case 'vec3<f32>':
      return (size: 12, align: 16);
    case 'vec4<f32>':
      return (size: 16, align: 16);
  }

  // matCxR<f32>: C columns, each a `vecR<f32>` padded to its own alignment.
  if (RegExp(r'^mat(\d)x(\d)<f32>$').firstMatch(type) case final m?) {
    final columns = int.parse(m.group(1)!);
    final (size: columnSize, align: align) = _sizeAlign(
      'vec${m.group(2)}<f32>',
      structs,
    );
    return (size: _roundUp(columnSize, align) * columns, align: align);
  }

  // array<E, N>: N elements on a stride of `roundUp(sizeof E, alignof E)`.
  if (RegExp(r'^array<(.+),\s*(\d+)>$').firstMatch(type) case final m?) {
    final (size: elementSize, align: align) = _sizeAlign(
      m.group(1)!.trim(),
      structs,
    );
    final stride = _roundUp(elementSize, align);
    return (size: stride * int.parse(m.group(2)!), align: align);
  }

  // A nested struct.
  if (structs[type] case final fields?) {
    final layout = _structLayout(fields, structs);
    return (size: layout.size, align: layout.align);
  }

  throw StateError('Unsupported WGSL uniform type "$type"');
}

/// Rounds [value] up to the next multiple of [multiple].
int _roundUp(int value, int multiple) =>
    ((value + multiple - 1) ~/ multiple) * multiple;
