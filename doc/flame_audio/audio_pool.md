# AudioPool

An AudioPool is a provider of AudioPlayers that leaves them pre-loaded with
local assets to minimize delays.

A single Audio Pool always plays the same sound, probably a quick sound
effect, like a laser shooting from your ship or a jump sound for your
platformer.

The advantage of using Audio Pool is that by configuring a minimum
(starting) size, and a maximum size, the pool will create and preload
some players, and allow them to be re-used many times.

You can use the helper method `FlameAudio.createPool` to create Audio
Pool instances using the same global `FlameAudio.audioCache`.