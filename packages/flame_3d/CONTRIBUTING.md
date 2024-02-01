# Contribution Guidelines

Read the main [Flame Contribution Guidelines](https://github.com/flame-engine/flame/blob/main/CONTRIBUTING.md)
first and then come back to this one.

## How To Contribute


### Environment Setup

First follow the steps described in the main [Flame Contribution Guidelines](https://github.com/flame-engine/flame/blob/main/CONTRIBUTING.md#environment-setup)

After you have followed those steps you can follow the steps to setup the Flutter GPU, you can 
follow the steps described in the [Flutter Wiki](https://github.com/flutter/flutter/wiki/Flutter-GPU#try-out-flutter-gpu). 

The engine commit that we have used for testing is `9e03a57cde8ae8d1811492653a4ca930986f53e3`. 

Once you have cloned the Flutter engine you can add the `flutter_gpu` as an override dependency 
to the `pubspec_overrides.yaml` file in the `flame_3d` directory and it's example:

```yaml
dependency_overrides:
  ... # Melos related overrides
  flutter_gpu:
    path: <path_to_the_cloned_flutter_engine_directory>/lib/gpu
```

Because this package is still experimental it depends on the beta channel, so switch to `beta` and
upgrade to the latest:

```sh
flutter channel beta
flutter upgrade
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