# Contribution Guidelines

Read the main [Flame Contribution Guidelines](https://github.com/flame-engine/flame/blob/main/CONTRIBUTING.md)
first and then come back to this one.

## How To Contribute


### Environment Setup

First follow the steps described in the main [Flame Contribution Guidelines](https://github.com/flame-engine/flame/blob/main/CONTRIBUTING.md#environment-setup)

After you have followed those steps you have to setup Flutter to use the specific build that this
package is built against:

```sh
cd $(dirname $(which flutter)) && git checkout 8a5509ea6a277d48c15e5965163b08bd4ad4816a -q && echo "Engine commit: $(cat internal/engine.version)" && cd - >/dev/null
```

This will check out the GIT repo of your Flutter installation to the specific commit that we require
and also gets us t he the commit SHA of the Flutter Engine that you need to use in setting up the 
Flutter GPU. For that you can follow the steps described in the 
[Flutter Wiki](https://github.com/flutter/flutter/wiki/Flutter-GPU#try-out-flutter-gpu). 

Once you have cloned the Flutter engine you can add the `flutter_gpu` as an override dependency 
to the `pubspec_overrides.yaml` file in the `flame_3d` directory and it's example:

```yaml
dependency_overrides:
  ... # Melos related overrides
  flutter_gpu:
    path: <path_to_the_cloned_flutter_engine_directory>/lib/gpu
```

After all of that you should run `flutter pub get` one more time to ensure all dependencies are 
set up correctly.


### Shader changes

If you have added/changed/removed any of the shaders in the `shaders` directory make sure to run the
build script for shaders:

```sh
dart bin/build_shaders.dart
```

This is currently a manual process until Flutter provides bundling support.