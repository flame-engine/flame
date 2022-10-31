# Audio


## Looping and Stopping Audio with AudioPlayers

```dart
import 'package:audioplayers/audioplayers.dart';

AudioPlayer? loopPlayer;
  
Future<void>startSound()async{
    loopPlayer = await FlameAudio.loopLongAudio('mylastsound.mp3');
}

void stopSound(){
    loopPlayer!.stop();
}
```
