# Bridge Packages

<style>
.package {
  display: flex;
  margin-bottom: 12pt;
}
.package > p:first-child { margin: 0 12pt 0 0; }
.package > p:first-child > a {
  background: #9b6814;
  border-left: 4px solid #ffc43c;
  box-shadow: 2px 2px 4px black;
  color: #ffffff;
  display: block;
  font-family: var(--font-mono);
  min-width: 110pt;
  padding: 8pt 10pt;
}
.package > p:first-child > a:hover {
  background: #d48f1d;
  text-shadow: 1px 1px 1px black;
}
.package > div.container > p { margin-bottom: 6pt; }
.package > div.container > p:last-child { margin-bottom: 0; }
</style>

:::{package} flame_audio

Play multiple audio files simultaneously (bridge package for [AudioPlayers]).
:::

:::{package} flame_bloc

A predictable state management library (bridge package for [Bloc]).
:::

:::{package} flame_fire_atlas

Create texture atlases for games (bridge package for [FireAtlas]).
:::

:::{package} flame_forge2d

A Box2D physics engine (bridge package for [Forge2D]).
:::

:::{package} flame_oxygen

Replace FCS with the Oxygen Entity Component System.
:::

:::{package} flame_rive

Create interactive animations (bridge package for [Rive]).
:::

:::{package} flame_splash_screen

Add the "Powered by Flame" splash screen.
:::

:::{package} flame_svg

Draw SVG files in Flutter (bridge package for [flutter_svg]).
:::

:::{package} flame_tiled

2D tilemap level editor (bridge package for [Tiled]).
:::

[AudioPlayers]: https://github.com/bluefireteam/audioplayers
[Bloc]: https://github.com/felangel/bloc
[FireAtlas]: https://github.com/flame-engine/fire-atlas
[Forge2D]: https://github.com/flame-engine/forge2d
[Rive]: https://rive.app/
[Tiled]: https://www.mapeditor.org/
[flutter_svg]: https://github.com/dnfield/flutter_svg


```{toctree}
:hidden:

flame_audio         <flame_audio/flame_audio.md>
flame_bloc          <flame_bloc/flame_bloc.md>
flame_fire_atlas    <flame_fire_atlas/flame_fire_atlas.md>
flame_forge2d       <flame_forge2d/flame_forge2d.md>
flame_oxygen        <flame_oxygen/flame_oxygen.md>
flame_rive          <flame_rive/flame_rive.md>
flame_splash_screen <flame_splash_screen/flame_splash_screen.md>
flame_svg           <flame_svg/flame_svg.md>
flame_tiled         <flame_tiled/flame_tiled.md>
```
