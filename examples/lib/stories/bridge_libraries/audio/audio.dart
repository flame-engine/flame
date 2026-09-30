import 'package:examples/commons/commons.dart';
import 'package:examples/commons/example_use_case.dart';
import 'package:examples/stories/bridge_libraries/audio/basic_audio_example.dart';
import 'package:flame/game.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookComponent audioStories() {
  return WidgetbookComponent(
    name: 'Audio',
    useCases: [
      ExampleUseCase(
        name: 'Basic Audio',
        builder: (_) => GameWidget(game: BasicAudioExample()),
        codeLink: baseLink('bridge_libraries/audio/basic_audio_example.dart'),
        info: BasicAudioExample.description,
      ),
    ],
  );
}
