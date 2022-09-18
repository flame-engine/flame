# Flame repository structure

The Flame repository is a monorepo which contains both the main Flame repository, and its
bridge packages.

Note that not all bridge packages have moved to the monorepo, so some may
still be on their own repositories, since this is a new organizational change and we are gradually
migrating all of them to this repository.


## Bridge packages

Bridge packages are packages which:

- Provides Flame with an interface to another external package (e.g. `flame_audio` which is
  Flame + Audioplayers, `flame_tiled`, which is Flame + tiled).
- Packages with features that are somehow very context specific and doesn't have a place inside the
  core package (e.g. `flame_splash_screen`).


## Index

- [Flame](./flame)
- [Flame Audio](./flame_audio)
- [Fire Atlas](./flame_fire_atlas)
- [Svg support](./flame_svg)
