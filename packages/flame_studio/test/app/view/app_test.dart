import 'package:flame_studio/app/app.dart';
import 'package:flame_studio/home/home.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockProjectRepository() extends Mock implements ProjectRepository;

class _MockComponentRepository() extends Mock implements ComponentRepository;

class _MockEditorPreferencesRepository()
    extends Mock
    implements EditorPreferencesRepository;

void main() {
  group(App, () {
    testWidgets('renders the home view', (tester) async {
      final projectRepository = _MockProjectRepository();
      when(projectRepository.getRecentProjects).thenAnswer((_) async => []);

      await tester.pumpWidget(
        App(
          projectRepository: projectRepository,
          componentRepository: _MockComponentRepository(),
          editorPreferencesRepository: _MockEditorPreferencesRepository(),
        ),
      );

      expect(find.byType(HomeView), findsOneWidget);
    });
  });
}
