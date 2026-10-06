# Example of a 3D object between 2D components

An animated 3D skeleton, loaded from a glTF file and rendered by
`flutter_scene` through a `Component3D`, placed between two regular Flame
layers: a `ParallaxComponent` scrolling behind it and a
`SpriteAnimationComponent` walking back and forth in front of it.

Rendering goes through Flutter GPU, which has to be enabled on native
platforms:

```sh
flutter run --enable-flutter-gpu
```

On the web no flag is needed.

The skeleton model is from the
[KayKit Skeletons](https://kaylousberg.itch.io/kaykit-skeletons) pack by Kay
Lousberg (CC0), and the parallax art is by Luis Zuno (CC0), see
`assets/images/parallax/license.txt`.
