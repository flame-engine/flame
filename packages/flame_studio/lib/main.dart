import 'package:flame_studio/app/app.dart';
import 'package:flame_studio/clients/clients.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter/widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final fileSystem = FileSystemClient();
  final storage = KeyValueStorageClient();

  final projectRepository = ProjectRepository(
    storage: storage,
    fileSystem: fileSystem,
  );
  final componentRepository = ComponentRepository(fileSystem: fileSystem);
  final editorPreferencesRepository = EditorPreferencesRepository(
    storage: storage,
  );

  runApp(
    App(
      projectRepository: projectRepository,
      componentRepository: componentRepository,
      editorPreferencesRepository: editorPreferencesRepository,
    ),
  );
}
