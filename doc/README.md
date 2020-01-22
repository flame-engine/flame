# Getting Started!

## About Flame

Flame is a minimalist Flutter game engine built on top of [Flutter](https://flutter.dev/).

## Goals

The goal of this project is to provided a complete set of out-of-the-way solutions for the common problems every game developed in Flutter will share.
Currently it provides you with: a few utilities, images/sprites/sprite sheets, audio, a game loop and a component/object system.

You can use whatever ones you want, as they are all somewhat independent.

## Learning resources

The community has created some articles and examples of a good usage of Flame.

Check out this great series of articles/tutorials written by [Alekhin](https://github.com/japalekhin):

 * [Create a Mobile Game with Flutter and Flame – Beginner Tutorial (Part 0 of 5)](https://jap.alekhin.io/create-mobile-game-flutter-flame-beginner-tutorial)
 * [2D Casual Mobile Game Tutorial – Step by Step with Flame and Flutter (Part 1 of 5)](https://jap.alekhin.io/2d-casual-mobile-game-tutorial-flame-flutter-part-1)
 * [Game Graphics and Animation Tutorial – Step by Step with Flame and Flutter (Part 2 of 5)](https://jap.alekhin.io/game-graphics-and-animation-tutorial-flame-flutter-part-2)
 * [Views and Dialog Boxes Tutorial – Step by Step with Flame and Flutter (Part 3 of 5)](https://jap.alekhin.io/views-dialog-boxes-tutorial-flame-flutter-part-3)
 * [Scoring, Storage, and Sound Tutorial – Step by Step with Flame and Flutter (Part 4 of 5)](https://jap.alekhin.io/scoring-storage-sound-tutorial-flame-flutter-part-4)
 * [Game Finishing and Packaging Tutorial – Step by Step with Flame and Flutter (Part 5 of 5)](https://jap.alekhin.io/game-finishing-packaging-tutorial-flame-flutter-part-5)

## Installation

Put the pub package as your dependency by dropping the following in your `pubspec.yaml`:


```yaml
dependencies:
  flame: ^0.17.3
```

And start using it!

## Topics

 * Core Concepts
   - [Structure](structure.md)
   - [Game Loop](game.md)
   - [Components](components.md)
   - [Input](input.md)
 * Audio
   - [General Audio](audio.md)
   - [Looping Background Music](bgm.md)
 * Rendering
   - [Images, Sprites and Animations](images.md)
   - [Text Rendering](text.md)
   - [Colors and the Palette](palette.md)
   - [Particles](particles.md)
 * Other Modules
   - [Util](util.md)
   - [Gamepad](gamepad.md)
   - [Box2D](box2d.md)
   - [Tiled](tiled.md)
   - [Debugging](debug.md)
   - [Splash screen](debug.md)
