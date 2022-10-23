# AudioPool

An AudioPool is a provider of AudioPlayers that are pre-loaded with
local assets to minimize delays.

A single AudioPool always plays the same sound, usually a quick sound
effect, like a laser shooting from your ship or a jump sound for your
platformer.

The advantage of using Audio Pool is that by configuring a minimum
(starting) size, and a maximum size, the pool will create and preload
some players, and allow them to be re-used many times.

You can use the helper method `FlameAudio.createPool` to create AudioPool
instances using the same global `FlameAudio.audioCache`.
