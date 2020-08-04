# Tiled

[Tiled](https://www.mapeditor.org/) is an awesome tool to design levels and maps.

Flame provides a package ([flame_tiled](https://github.com/flame-engine/flame_tiled)) which bundles a [dart package](https://pub.dev/packages/tiled) that allows you to parse tmx (xml) files and access the tiles, objects and everything in there.

Flame also provides a simple Tiled class and its component wrapper TiledComponent, for the map rendering, which renders the tiles on the screen and supports rotations and flips.

Other advanced features are not yet supported but you can easily read the objects and other features of the tmx and add custom behaviour (eg regions for triggers and walking areas, custom animated objects).

You can check a working example [here](https://github.com/flame-engine/flame_tiled/tree/master/example).
