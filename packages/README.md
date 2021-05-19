# Flame repository structure

Flame repository is a mono repository which contains both the main Flame repository, and it's
bridge packages.

Note that not all bridge packages have moved to the mono repo, so some may
still be on their own repositories, this is a new organization and we are gradually migrating
all of them to this repository.

## Bridge packages

Bridge packages are packages which:
 - Unites Flame with another external package (e.g. `flame_audio` which is Flame + Audioplayers, `flame_tiled`, which is Flame + tiled)
 - Packages with features that are some how very context specific and don't have a place inside the core package (e.g. `flame_splash_screen`)

## Index
 - [Flame](./flame)
 - [FireAtlas](./fire_atlas)
