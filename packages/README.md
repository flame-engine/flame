# Flame repository structure

The Flame repository is a monorepo which contains both the main Flame package and other so-called
bridge packages.


## Bridge packages

Bridge packages are packages which:

- Provides Flame with an interface to another external package (e.g. `flame_audio` which is
  Flame + Audioplayers, `flame_tiled`, which is Flame + tiled).
- Packages with features that are somehow very context specific and doesn't have a place inside the
  core package (e.g. `flame_splash_screen`).

While most of the officially supported bridge packages live in this monorepo, a few can be found
under Flame Engine's GitHub organization. There are also many bridge packages developed and maintained
by other members of the community.
