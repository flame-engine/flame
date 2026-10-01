## 0.8.4

**An actor system with several foci.** `ActorSystemComponent(foci:)` steps
the system towards every player of a co-op game, so each actor goes for the
one it can reach first; it could only name one focus, and every monster went
for player one. Its `flutter3d_sim` dependency asks for `^0.8.1`.

**A step's reports survive the game's own logic.** In a `HasFixedStep` game
the actor system's step is opened at the start of each step, through the new
`HasFixedStep.beforeEachStep`, rather than just before the actors: a monster
killed by a shot fired in the game's `fixedUpdate` was wiped from `died`
before anything read it.

**A body the game moves is drawn between its steps.** `StepClock` and
`StepFollower` are what draws between steps asks of what steps; the game is
one (`HasFixedStep`), as are `ActorSystemComponent` and
`PhysicsStepComponent`. `ActorComponent.stepper` takes any of them and
`CharacterBodyComponent` takes one: a body the game's own simulation moved
kept its place after the move and was drawn with no smoothing.

**An actor and its component live and die together.** An `ActorComponent`
whose actor the simulation removed takes itself out; one handed
`removesFrom` takes the actor out of the system when it goes. The actor used
to go on thinking unseen, or the node to stand where the actor had been.

**A horde in one draw.** `InstancedActorComponent` draws a simulated actor
as a slot of a shared `InstancedMeshNode`, between its steps, and
`InstancedPoseComponent` does the same for anything the simulation keeps
that is not an actor, a shot say. Two hundred monsters were two hundred
nodes.

**Keys from the keyboard, not the focus.** `listenToKeyboard()` on a
`FlameInputBridge`, `PlayerInputs` and the new `PlayerSeats` reads keys
from `HardwareKeyboard`: through the game's focus, a key held while an
overlay took it was held for good. `PlayerSeats` keeps every way of holding
the game and lets players claim one by pressing, in the order they join.

**A level is a scene.** `HasFlutter3d.replaceScene3d` moves the game to the
next level's scene with the camera, and `Flutter3dFlameWidget` draws the
game's scene as it is now. `FixtureVisualsComponent` syncs a level's
fixtures once a frame and lets them go with the level. `ViewCamera` eases a
camera towards wherever a function says, for a view no single component
decides — a whole party's.

**The steps no longer walk the whole game every frame.** `HasFixedStep`
keeps its list of `FixedStepUpdate` components and walks the tree again only
when one comes, goes or changes priority: a game with a horde walked hundreds
of components sixty times a second to find the few that step.

**A pad is read against the frame it is read in.** `HasFixedStep.frameSeconds`
is this frame's time, set before `beforeSteps`; the pad feed used the frame
before's, nought on the first frame and the stall's after one.

**The camera sync follows Flame's camera wherever it is added — again.**
0.8.3 ordered a `CameraSyncComponent` flowing Flame to the scene after
Flame's `CameraComponent` by its priority, and a priority orders siblings
only: added to the world, where a game adds its components, it ran inside
the world, before the camera, and the 3D camera trailed `camera.follow()`
by a frame once more. `UpdatesAtRoot` is what fixes it and the two others
with the same assumption: a component with it, mounted anywhere but the
game's root, does its frame's work from a driver at the root at its own
priority. The input step's end has it, so a press closed from the world is
still seen by a button in the viewport, and so has
`flame_flutter3d_audio`'s `AudioSceneComponent`.

**An upright billboard turns about its own plane's normal**, and writes its
rotation only when it changed. It turned about world Y whatever the plane, so
on a backdrop the card swung about an axis lying in it, and a still card under
a still camera marked its node moved every frame.

## 0.8.3

**A host that goes lets go of the game.** `Flutter3dFlameWidget` cleared
the game's `redrawer3d` by comparing it with a fresh tear-off of its own
method, which is never identical, so a game that outlived its widget kept
the disposed host and everything it held.

**Only a host showing the game ticks it.** A host added its clock on its
first build; one still opening its device, or one that failed to start,
ticked a game another host was showing, and `onTick` ran twice an update.

**New overlay builders reach the screen without a new `GameWidget`.** A map
written inline in a parent's `build` is new on every rebuild, and each one
replaced the `GameWidget`, which updated the game again from its layout.
Builders under the same names are now read through the current config.

**`BillboardAtlas` keeps what it uploads straight.** A material is kept per
image and sampling, so a smooth caller no longer gets a sharp one's; an
upload that finishes after `dispose` makes no texture; and textures go back
after the frames in flight, as the cards do.

**A character or a lift leaves the world with its component.**
`CharacterBodyComponent` and `KinematicBodyComponent` take `removeFrom`, as
`RigidBodyComponent` does; a despawned one no longer stays solid and unseen.

**A game shown again draws the world it kept.** Flame keeps a game's
components when its widget goes, and the same game can be shown again on a
tab that comes back. `Flutter3dFlameWidget` closed the device it had opened
under a world still built on it, and the game came back with meshes on a
closed device and no particles. The device now goes with the game:
`HasFlutter3d.close3d()` lets it go, `dispose()` calls it, and
`onClose3d` is where a game that will be shown again takes down what it
built.

**Another game handed in gets a world of its own.** A rebuild with a
different `game` drew the new game over the old one's scene; the widget
now starts afresh for it. A scene or renderer that threw on the way up no
longer leaves its device open, and a world that throws while it is built
says why where the game would be. A camera a rebuild replaced is taken out
of the scene, and new overlays or focus reach Flame's widget.

**A paused game can be drawn.** `HasFlutter3d.redraw3d()` draws the 3D
layer once without an update, for a pause menu that changes the sky.

**A flipped component turns the way Flame draws it, nested or not.**
Flame's `absoluteAngle` is reflected for a flipped component, and written
beside the signed scale the mirror was applied twice: a flipped ship under
anything turned the opposite way. The chain is now folded the way Flame's
matrices compose it, on the way out and on the way back, for both bridged
components. A plain `Component` between a component and a positioned
ancestor no longer hides the ancestor.

**A press is seen by one step.** In a `HasFixedStep` game the input step
is closed after each fixed step rather than each frame: a frame of three
steps showed a jump's press to all three. `HasFixedStep.afterEachStep`
is where it is closed. `PhysicsStepComponent` and `ActorSystemComponent`
in such a game step in the game's steps, in tree order, and draw by its
`alpha`, rather than counting steps of their own.

**Contacts end when a partner goes.** A component removed mid-contact
ends the contact on the other side, as Flame's own hitboxes do; the other
side went on counting it among its `activeCollisions`. `ColliderRegistry`
keeps a component moved to another parent, and finds a removed one again
when it is added back.

**Bodies can be moved and let go of.** `RigidBodyComponent.teleport` puts
a body somewhere still and awake and draws it there at once; written into
the collider, a respawn slid across the level. Handed `removeFrom`, a
removed crate takes its body out of the world instead of leaving it solid
and unseen. A component added back draws from where its body is.

**Touch that moves keeps holding.** `PointerTrack` holds its action
through a drag of the same finger, which Flutter reports as a cancelled
tap; firing while dragging to aim stopped the moment the aim moved. It and
`SwipeInput` pass drags on to what is under them, a stick say. A touch
stick at rest writes its zero once, not every frame over a pad's stick,
and takes a `deadZone`. A window that loses focus lets go of every key.

**A wrapped world tells a contact once.** Two craft by the same edge met
really and through their ghosts, two across the seam through each one's
ghost, and every hit was reported twice. A ghost now tells its owner of a
meeting only when nothing else will. A ghost has its owner's hitbox's
collision type, solidity and shape, polygons included, and its meshes take
the owner's tint and opacity every frame.

**What a component makes, it gives back.** A `CellGridComponent` removed
gives back the mesh it was standing in. A `Particles3dComponent` added back
is drawn again as before. A `TrailComponent` widens its line against the
new size after a resize, breaks rather than drawing across the world when
its component jumps further than `breakAt`, and can `reset()`.

**Flame's events land through any viewport, and the sky is the horizon.**
`ProjectedViewfinder` brings Flame's viewport points into the canvas the
projector works in, so a `FixedResolutionViewport` no longer puts every tap
somewhere else. A point on the sky comes back as the plane point out at the
horizon, through `BridgeProjector.onPlaneOrHorizon`, rather than NaN: Flame's
`World` takes every point, and a drag that strayed above the horizon moved
its component to NaN for good.

**What reads Flame's camera runs after it.** Flame gives its
`CameraComponent` the highest 32-bit priority, and the clock, the sound and
the input's end sat below it, so a 3D camera synced from a viewfinder that
`camera.follow()` moves trailed it by a frame. `BridgePriority` now has
`flameCamera` and `afterFlameCamera`, the three run past it, and a
`CameraSyncComponent` flowing Flame to the scene runs after Flame's camera
by default. `CameraSyncController.takeRest` takes a camera's rotation as its
rest after a `lookAt`, and the lens is made only when the zoom moves.

**An instance is a bridged component too.** `Bridged3d` is what taps and
hitbox outlines ask of a component, and `InstancedObject3dComponent` is
one: an invader drawn as one instance of fifty-five can be tapped and have
its hitbox drawn, and takes a `space` as a node does. Hitbox outlines bend
with a component's space.

**Taps are nearest where they meet, and have an end.** `Taps3dComponent`
ranks what is under a tap by where the ray enters each box, not by each
box's middle, so a crate standing on a wide field hears the tap rather
than the field. `Tap3dCallbacks` hears the finger lift (`onTapUp3d`), the
tap given up on (`onTapCancel3d`) and a finger held still (`onLongTap3d`).
`BridgeProjector.rayThrough` is the ray through a screen point.

**A tint moves as a colour effect would.** `TintEffect` moves a bridged
component's tint on any `EffectController`, since Flame's own `ColorEffect`
wants a paint a 3D component does not have.

**A clip can be played again.** `ModelAnimationComponent.play` takes
`restart`: asking for the clip already playing did nothing, so a jump
played once a game.

**The day's fog reaches the frame.** `AtmosphereComponent` writes its fog
into `HasFlutter3d.fog3d`, which the game's default settings draw with; a
game had to know to read it across by hand.

**An actor turns between its steps.** `ActorComponent` draws its facing
the same fraction of the way between two steps as its place, the short way
round; the place glided and the facing clicked. Added back, an actor or a
body draws from where it is, not from where it was when it went.

**Nothing behind an orthographic camera is on the screen.**
`BridgeProjector.toScreen` returns null for a point behind an orthographic
camera, as it did for a perspective one.

**A touch stick is read before the steps.** In a `HasFixedStep` game the
steps run before any component updates, and a stick read in its own
component reached them two frames after the finger moved.
`HasFixedStep.beforeSteps` is where what the steps read is gathered.

**`onCollision` once a frame, and a ray through the world.** A
`CollisionBridge` handed its `stepper` relays `onCollision` once a frame
for each partner, as Flame's own detection does, rather than once a step;
`PhysicsStepComponent.frame` counts the frames. `ColliderRegistry.raycast`
fires a ray across the plane through the collision world, exact per shape,
with layers and triggers, and says which component it met and where.

**A wrapped world carries bodies across, and its ghosts can be tapped.**
A child of a `WrapSpace` placed from the scene side, a body the physics
steps, is carried across the seam in the scene as well, still moving,
through `Object3dComponent.shiftScene`, which a rigid body, an actor and a
character body override to move their bodies; its Flame position was
wrapped and read straight back from the body on the far side. A tap on a
craft's ghost reaches the craft: `Tap3dCallbacks.drawnBoxes3d` includes
`WrapSpace.ghostBoundsOf`.

**Flame's camera drives a perspective one.** Given an `eyeOffset`, a
`CameraSyncController` flowing Flame to the scene looks at the
viewfinder's point from that offset, nearer as the viewfinder zooms and
round as it turns: Flame's `follow` with its `maxSpeed`, `setBounds`,
`moveTo` and effects on the viewfinder all move the 3D camera, as they
would a flat Flame game. Before, a perspective camera was put on the plane
at the viewfinder's point. `ProjectedViewfinder` works out Flame's
`visibleWorldRect` from what the 3D camera shows, so `canSee` and bounds
that mind the viewport are right under a perspective lens.

**A split screen.** `HasFlutter3d.viewport3d` is the part of the canvas the
game's camera draws into, and `moreViews3d` are further views drawn into
the same frame: the second player's half, a mirror. `BridgeProjector` takes
a `viewport`, so taps and labels work in each half. Needs
`flutter3d_app` 0.8.1, whose `SceneSurface` draws more than one view.

**Players at one machine, and a pad on Flame's clock.** `PlayerInputs`
hands each key to every player's `FlameInputBridge`, so two on one
keyboard each move their own; forwarded to one bridge, player two's arrows
moved player one. `FlameInputBridge.followPad` ticks a `PadInput` in each
frame, before the steps of a `HasFixedStep` game: nothing ticked one in a
Flame game. A second player's controller is a `PadInput` over
`Gamepad(index: 1)`, which `pad_input` 0.4.3 reads.

**An isometric board.** Under an orthographic lens `eyeOffset` is the angle
of view: the camera looks along it, and the zoom stays the lens's height.

**A lift Flame moves.** `KinematicBodyComponent` moves a kinematic collider
to where Flame puts it, with Flame's own effects, through `Collider.moveTo`,
so a character standing on it is carried; a step in which it did not move
clears the motion, so the passenger is carried once for each move and not
again on every step after. Written into the collider by hand, the lift moved
and its passenger stayed. `BridgePriority.kinematic` runs it before the
actors and the physics.

**A grid is a world to move and collide in.** `CellGridComponent` can draw
its cells `instanced`, each a slot in one batch, so a cell taken or put back
is one slot rather than the whole grid rebuilt: a field dug a cell at a time
rebuilt thousands of blocks for each swing of the spade. With `hitboxes`,
each cell has a solid, passive Flame hitbox of its own, taken with it, so
Flame's own collision and raycast meet the walls. `setCell` grows a grid as
well as wears it, and `cellAt` and `centreOf` turn points into cells and
back. `GridMover` is a behaviour that walks its parent from the middle of
one cell to the next: a turn asked for is kept until a junction opens to
it, a turn back is taken at once, a wall stops it, and with `wraps` a way
off one edge comes in at the other.

**A level drawn in Tiled.** `TiledWorld3d` stands a `TiledMap` up in 3D,
the map `flame_tiled`'s `TiledComponent` reads or `TileMapParser` parses:
each tile layer becomes a `CellGridComponent` with a block where a tile is,
set up by its custom properties in Tiled (`solid` for Flame hitboxes,
`depth`, `elevation`, `merged`) and painted its tint colour, and each object
is handed to the game with its middle in metres. A maze, a castle's rooms
or a mine's shafts are drawn in the editor instead of typed as masks.

**Flame's own physics, drawn in 3D, and a game of any world.**
`Object3dComponent.follows` takes any of Flame's position providers, and an
angle provider's angle too: a `flame_forge2d` `BodyComponent` is both, so a
pinball's ball and flippers moved by forge2d's solver are drawn in 3D. A
forge2d body is not a `PositionComponent`, and nothing of the bridge could
be hung under it. `HasFlutter3d` and `HasFixedStep` are generic over the
game's world: on `FlameGame` alone they could not be mixed into a
`Forge2DGame`, or any game whose world has a type of its own.

**Flame's sprites stand in the scene.** `SpriteBillboardComponent` draws a
Flame `Sprite`, or a `SpriteAnimation` played by Flame's own ticker, on a
card that turns to face the camera, upright about the plane's normal or
squarely, its foot on the plane: a car on a road, a tree beside it, an
explosion. The image goes to the device once, each frame is a card of its
own corners, and it is drawn unlit, cut out where the sprite is clear and
sampled nearest, as pixel art wants.

**A Flame component in full 3D.** `Node3dComponent` is a Flame component
with a place, a quaternion turn and a scale on each axis in the scene, no
plane under it: a starfighter, a tank on an open plain. Under another it
hangs from its parent's node, so a turret turns with its tank, and a camera
added to a ship's node is a cockpit. `Move3dEffect`, `Rotate3dEffect` and
`Scale3dEffect` move it on any of Flame's `EffectController`s, `TintEffect`
and `OpacityEffect` colour and fade it, and `Tap3dCallbacks` hears a tap on
it: taps now ask for `Drawn3d`, what is drawn and where, which every bridged
component is too.

**Billboards share their pictures, and a one-shot goes.** `BillboardAtlas`
holds one texture and one material for each image and one card for each
part of it a frame shows, so a bank of reeds drawn from one sheet uploads
it once and draws as one; a billboard handed none makes its own.
`SpriteBillboardComponent.removeOnFinish` takes a one-shot animation away
when it has played, as `SpriteAnimationComponent`'s does. River Sortie
stands reeds and bushes along its banks and a flash in each blast.

**A billboard can say something.** `BillboardAtlas.spriteOfText` writes a
string with Flame's `TextPaint` into a sprite of its own, in whatever font,
weight, colour and shadows the paint has, for a sign by the road or a name
over a craft. `SpriteBillboardComponent.smooth` samples it linearly, as
lettering wants, and a billboard's `sprite` can be changed while it stands:
a new picture is uploaded first and the card keeps the old one until it is
there. River Sortie's fuel depots say FUEL, as they always have.

**Moved is not gone.** Flame moves a component to a new parent by removing
and mounting it, and a component's `owns` meshes were let go of in the
removal while it went on drawing them.

**Flame's effects reach the scene in the frame they happen.** Flowing Flame
to the scene, `Object3dComponent` writes the scene again in `updateTree`,
after its children, and an effect is a child: written only in `update`,
before them, every `MoveEffect` and `RotateEffect` drew a frame late. It
still writes in `update` as well, so code that drives a component by
calling `update` itself, as the showcase's transform page does, keeps
working. Flowing the other way it reads the scene in `update`, so its
children see this frame's body.

**A nested component lands where Flame draws it.** The transform written
into the scene is the absolute one, so a component under another, a frog
on a log, is placed at the log plus the frog. It wrote its local position
as a world one. Read back from the scene, a nested component's position is
brought into its parent's space.

**A component let go stops being drawn at once.** `removeFromParent` hides
its node straight away; Flame takes the component out on its next
lifecycle pass, and until then the node was drawn a frame too long.

**The rest of Flame's transform crosses.** `elevation` lifts a component off
its plane along the normal, so one plane serves what floats and what flies
over it; `scenePosition` says where it is in the scene. Flame's `scale`
scales the node. Flame's visibility (`HasVisibility.isVisible`) hides and
shows it, written only when it changes, so a node blinked by hand still
blinks. And `visual`, a node under the bridged one made on first use, is
the game's to turn, bank or tilt: the bridge writes the bridged node's
rotation every frame and never touches `visual`'s. River Sortie dropped its
second plane, its hand-made pivot nodes and its node-level show and hide;
Meteor Yard its pivot map.

**`Flutter3dFlameWidget.onRendererReady`** hands a game the `Renderer` the
3D layer draws with, once it exists, for what only the renderer can do:
letting go of a streamed mesh after the frames in flight
(`Renderer.releaseMeshAfterFrame`), adding a contributor.

**`Object3dComponent` takes a `size` and an `anchor`.** A bridged component
that collides needs both: a `RectangleHitbox()` fills its parent's size, and
the anchor decides whether the point written into the scene is the centre
or the top-left corner. They were Flame's and set in every subclass's
constructor body, five times in River Sortie alone; they pass through the
constructor now.

**A phone's stick and button go through the input bridge.**
`FlameInputBridge.followJoystick(stick)` returns a component that writes a
Flame `JoystickComponent`'s deflection into the move axis every frame,
screen-up as forward, the way a gamepad's stick goes in; `bindButton(button,
action)` holds an action while an on-screen button is down. River Sortie
polled its stick in `update` and wired the button's three callbacks itself.

**`ChaseCamera` follows a bridged component in perspective.** From an
offset behind it, looking at a point ahead, following part way across if
asked, stiff or springy. It eases through `flutter3d_sim`'s `CameraRig`,
so `chase.rig.shake(0.5)` shakes it and a `CollisionWorld` with walls in it
keeps it out of them. `ChaseCameraComponent` runs one as a component.
River Sortie's hand-written camera went, and its camera shakes when the jet
goes down.

**`BridgeProjector` goes between the 3D camera and Flame's screen.**
`toScreen` says where a point of the scene is drawn, for a label or a
"+30" in Flame's viewport over a craft; `onPlane` says which point of a
plane is under a touch.

**`ChunkStreamer` builds an endless world piece by piece.** Given how a
piece is built and let go, `cover(from, to)` builds what came into view,
in order, and drops what left it; `clear` drops everything for a restart.
River Sortie's stretches of river are one.

**`InstancedObject3dComponent` draws many small things as one.** A Flame
component that takes a slot in a shared `InstancedMeshNode` while mounted,
writes its transform into it the way `Object3dComponent` writes a node's,
and gives it back when removed, at once. River Sortie's shots are one draw
however many are in the air.

**`Particles3dComponent` runs a `flutter3d_particles` system on Flame's
clock**, bursting from a Flame point with `burstAt`, and draws it through a
`MeshParticleContributor` once `drawWith` has the renderer, additively by
default or with `blend: MeshParticleContributor.darkening` for smoke. River
Sortie's fire, sparks and spray went into one pool and its smoke into
another, and `BurstComponent`, a scene node per shard, is gone. The package
now depends on `flutter3d_particles` 0.8.1, which is plain Dart.

**A platformer's runner, reached from Flame.** `CharacterBodyComponent`
carries a bare `CharacterController` across the bridge and steps it with
`drive`, in the game's fixed steps when it has them: a
`flutter3d_game_platformer` runner, which already runs, jumps twice and
climbs ladders and ropes, moved by its own rules and drawn between steps.

**A day, a worn shield and a missile's trail.** `AtmosphereComponent` runs
an `AtmosphereCycle` on Flame's clock and puts the air on the game's scene,
its sun and its sky, with the fog for its `renderSettings`.
`CellGridComponent` is a `CellGrid` drawn as blocks, whose `hitAt` wears
away the cells round a point and says whether the shot met one, drawing
what is left and letting the old mesh go. `TrailComponent` lays a
`LineStripNode` behind the bridged component it is added to.

**A road that bends under Flame's straight world.** `BridgeSpace` is where
a Flame point is placed and turned in the scene; `BridgePlane` is the flat
one, and `CurvilinearSpace` lays Flame's world along an `OpenPath`: `x` is
metres right of the road's middle, `-y` metres along it, and an angle turns
from the road's heading. `Object3dComponent(space:)` writes through it, so
an Enduro car keeps Flame hitboxes that mean side by side on the road
however the road winds.

**A world whose edges meet.** `WrapSpace` wraps its children's positions
round a rectangle, draws a ghost of each child within `margin` of an edge
on the other side (three in a corner) so a ship half over an edge is seen
on both, and gives the child ghost hitboxes one world across, so Flame's
own collision detection finds a contact across the seam and reports it to
the child itself. `shortestWay` is the direction across an edge when that
is shorter.

**An orthographic camera agrees with Flame to the pixel, and rolls.**
`CameraSyncController` takes a `viewportHeight`: with it, Flame's zoom is
pixels per world unit, the viewport's height over the camera's, rather
than the reciprocal convention that moved the right way and matched
nothing on screen. `syncAngle` keeps Flame's viewfinder angle and the
camera's turn about the plane's normal the same.

**`Flutter3dFlameWidget` passes Flame's overlays and focus on**:
`overlayBuilderMap`, `initialActiveOverlays`, `focusNode` and `autofocus`
reach the `GameWidget`, so a pause menu over the 3D layer is Flame's own
overlay rather than a second `Stack`.

**A model's animations play on Flame's clock.** `ModelAnimationComponent`
advances a loaded model's `AnimationPlayer` in its own update, so it stops
when the game is paused, and changes clip by name with a crossfade; asking
for the clip already playing does nothing, so a game can ask every frame.
`MeshFlipbookComponent` shows a handful of meshes in turn, an invader's two
poses.

**Flame's own events land where the player sees things.**
`ProjectedViewfinder` maps the screen to the game's plane through the 3D
camera: a component's `TapCallbacks`, Flame's hit test and
`camera.globalToLocal` in a game's code find the plane point under the
finger, where the viewfinder's affine transform put it metres away under a
perspective camera. The sky meets no plane and hits nothing. It changes
events and conversions; Flame still draws its world flat.

**A component lets go of the meshes it made.** `Object3dComponent(owns:)`
names meshes built for one component, a bridge's span, and gives them back
when the component is removed: through the renderer after the frames in
flight in a `HasFlutter3d` game, at once when there is no renderer. River
Sortie's bridges own their span and shield.

**An actor hears its contacts, and an instance has a colour.**
`CollisionBridge` relays to any component with Flame's collision callbacks,
an `ActorComponent` among them, rather than only a `RigidBodyComponent`;
a component that is not bridged is given a plane. `InstancedObject3dComponent`
has a `tint` and is an `OpacityProvider`, written into its slot's colour:
a hit flash on one invader of many.

**A game's own logic can run in fixed steps.** `HasFixedStep` on a
`FlameGame` spends each frame's time in steps of one size and calls
`fixedUpdate` on the game and on every `FixedStepUpdate` component in each
step, before Flame's once-a-frame `update`. The physics and the actors
already stepped so; a jet flown by `speed * dt` did not, and the same
second of play flew a different distance at 30 and at 120 frames a second.
`stepEnd` leaves the input step open after a frame with no step in it, so
a press is not closed before anything has read it. River Sortie's run, its
targets, bridges and shots are in fixed steps now.

**A body at rest costs nothing either.** `RigidBodyComponent` and
`ActorComponent` wrote their body's place onto the node every frame, and a
sleeping crate redrew every shadow as a still prop had. They write through
`placeNode` and `turnNodeTo`, which leave a node alone where it already is.

**The input step closes itself, and the pointer and swipes are input.**
`FlameInputBridge.stepEnd()` is a component that calls `endStep` once
everything has read the frame's input, which each game did by hand as the
last line of its `update`. `pointer(press:)` follows the pointer as an
`aim` and holds an action while a tap is down; `swipes(...)` turns a swipe
into one press of its direction's action.

**A still prop costs nothing, and no shadow is redrawn for it.** A node's
setters mark it changed whatever they are given, and the engine keeps its
shadow cascades and its bounds tree only while nothing changed. Every
bridged component rewrote its place every frame, twice, so one still
tanker had every shadow redrawn every frame. `Object3dComponent` and
`InstancedObject3dComponent` now write only when Flame's transform moved,
without making a vector or a quaternion to do it; `BridgePlane.to3dInto`
and `rotationInto` are the allocation-free forms. `rewriteScene` forces
the next write for a caller that moved the node itself.

**`BridgePriority` names the order a bridged frame runs in**: input, the
actors, the physics, the game's own components at Flame's default, the
camera, the sound, the clock. The bridge's components take those numbers
by default; each game had picked its own (the arcade -120 and -110).

**`ColliderRegistry` is the collider-to-component map every game with
contacts kept by hand.** An entry leaves when its component leaves the
game, and `bridge` makes a `CollisionBridge` that looks the other side up
there. The arcade's own map went.

**`Flutter3dFlameWidget` follows a rebuild.** A new camera or clear colour
handed in from above is drawn with, and a new camera is added to the
scene; both went into the view once and a rebuild changed nothing on
screen. In a debug build it says so when the game paints an opaque
background over the 3D layer, rather than leaving a screen of one colour.

**Flame's opacity and a tint reach the 3D layer.** `Object3dComponent`
is an `OpacityProvider`, so Flame's `OpacityEffect` fades every mesh under
its node, and its `tint` colours them, through `MeshNode.tint`; a model
dressed onto the node later takes them too. River Sortie's wrecks go down
charred and a fallen bridge fades under the water rather than blinking out.

**A tap lands on what the player sees.** Flame's `TapCallbacks` asks a
component whether a point is inside it on the plane the game plays on,
which under a perspective 3D camera is not where the component is drawn.
`Tap3dCallbacks` on a bridged component hears `onTap3d` when a tap falls on
the screen rectangle its node covers, through the game's projector, and a
`Taps3dComponent` in a `HasFlutter3d` game hands each tap to the nearest
such component under it, or lets it through to the rest of Flame.
`BridgeProjector.boundsOf` gives the screen rectangle of a box.

**Hitboxes can be seen where they are.** Flame's `debugMode` draws a hitbox
flat on its own canvas, nowhere near a craft drawn in perspective.
`HasFlutter3d.debugHitboxes3d` draws every bridged hitbox in the scene,
round its craft at its height, green, and red while it collides;
`addHitboxes3d` is the same for any `DebugDraw`. River Sortie shows them
with `--dart-define=RIVER_HITBOXES=true`.

**Physics and actors step in fixed steps.** `PhysicsStepComponent` and
`ActorSystemComponent` passed Flame's `dt` straight to the solver, so the
same jump reached a different height on a faster screen and a stalled frame
let a fast body step through a wall. Both now spend the frame's time in
steps of one size through `flutter3d_sim`'s `FixedStep` (a sixtieth of a
second unless given `step:`), at most five of them after a stall, and
dispatch contacts after each step. A `RigidBodyComponent` or an
`ActorComponent` given the component as its `stepper` is drawn `alpha` of
the way between its last two steps rather than jumping from one to the
next.

**`HasFlutter3d`: a Flame game owns its 3D world.** Mixed into a
`FlameGame`, it gives the game its `scene`, `device`, `camera3d`,
`renderer` and `projector`, a `clearColor` and `renderSettings()` the frame
is drawn with, and a transparent background. The game builds its world in
`onOpen3d` and uses the renderer in `onRenderer3d`, each run once, after
the game has loaded, whichever order the widget or a test opens things in.
`Flutter3dFlameWidget(game: game)` then needs nothing else: `camera` and
`buildScene` are optional for such a game, and still work for any other.
River Sortie's `main.dart` went from the scene, the camera, the lens, the
haze, the projector, the renderer and the chase camera to the game alone.

**A hidden parent hides its bridged children.** Flame does not draw the
children of a component it hides, and a child's scene node is not under its
parent's, so the child went on being drawn in 3D while the log it rode on
blinked. A bridged component now shows its node only while it and every
ancestor with `HasVisibility` are visible; `shownInFlame` answers that.

**A child under a scaled parent is scaled by both.** Its place already
carried the parent's scale, and its node was scaled by its own alone, so the
model and the hitbox disagreed about its size. The node takes Flame's
absolute scale. The same two fixes reach `InstancedObject3dComponent`.

**`ActorComponent` turns with its actor**, by the actor's yaw, and copies
the body only when the scene is authoritative. It and `RigidBodyComponent`
take a `size`, an `anchor` and an `elevation`, as `Object3dComponent` does:
a `RectangleHitbox()` on a bridged rigid body filled a size of nothing.

**`Flutter3dFlameWidget` is tested.** Its two tests were skipped as hanging
under `flutter_test`; run directly, both finish in seconds.

## 0.8.2

**`PhysicsStepComponent` steps the physics on Flame's clock.** A
`RigidBodyComponent` never steps the shared world, so every bridged game
wrote the same small component to do it once a frame: the arcade, the
example, each its own copy. It is public now. It calls `Dynamics.step`, then
an optional `afterStep` for anything that follows a body the solver just
moved (a trigger sensor riding on a solid body), then `CollisionWorld.update`,
which is what sends contacts to a `CollisionBridge`. Give it a priority below
the components that read the bodies.

**`Flutter3dFlameWidget` closes the device it opened.** Without `existing`
it opens a `GraphicsDevice` and a `Renderer` of its own, and it never
released either: a page that came and went left a GPU context behind each
time. It now disposes both with itself, and still leaves a pair passed in
through `existing` to whoever passed it. It also takes its `BridgeClock` off
the game when it goes, so a game that outlives the widget stops calling
back into it, and a rebuild that hands in a different game moves the clock
to the new one. Before, the new game never got a clock, and the 3D layer
stopped following it.

**A removed component hears no more contacts.** `CollisionBridge` relayed
to its component whether or not it was still in a game, so a ship removed
on one frame could still be told it hit something on the next. Flame's own
collision system does not call a removed component, and now the bridge does
not either. `CollisionBridge.detach()` clears the collider's listener, for
a collider that outlives its component.

**`ActorSystemComponent` takes a `priority`** in its constructor, as every
other component does.

**`CameraSyncComponent` runs a `CameraSyncController` as a component**, for
a game that would rather order the camera sync among its components than
tick it from `onTick`. The controller itself is unchanged.

**`FlameInputBridge.onGameKeyEvent`** answers a `FlameGame`'s
`KeyboardEvents.onKeyEvent` in its own `KeyEventResult`. `onKeyEvent` answers
a component's `KeyboardHandler`, whose `true` means "keep propagating", and
every game that forwarded to it wrote the flip to `ignored`/`handled` by
hand.

**A Flame turn on a ground plane is no longer drawn mirrored.**
`BridgePlane.rotationFor` took its sign from `Quaternion.rotated`, which
computes `q̄·v·q` and turns a vector by `-θ`, while a node is drawn through
its matrix, which turns by `+θ`. On `BridgePlane.ground` a Flame angle of
+0.5, clockwise on screen, was drawn anticlockwise; on a backdrop the two
sign flips cancelled and it came out right. `rotationFor` and `angleFor` now
both work through the matrix a node is drawn with, and a test checks where
the node is drawn on every plane, where the old ones only checked that an
angle survived the round trip, which it did either way. An
`Object3dComponent` syncing rotation `flameToScene` on the ground plane turns
the other way than it did, which is the way Flame means.

**Flame is updated once a frame, not twice.** The bridge redrew the 3D layer
with a `setState` on the whole `Stack`, which rebuilt `GameWidget` every
frame, and `GameWidget` calls `game.update(0)` from its layout whenever it is
rebuilt: every frame the game updated twice and `onTick` saw a second call
with a `dt` of zero. Now only the 3D layer is rebuilt, and the `GameWidget`
is made once per game, so a rebuild from above (a HUD beside it) does not
reach Flame either.

It asks for `flutter3d_physics` `^0.8.2`, which brings the cloth fix.

## 0.8.1

**An example to start from.** `example/` is the smallest hybrid game: a Flame
HUD over a 3D yard, a cube whose Flame position drives its scene node, and a
crate that falls under `flutter3d_physics` onto a trigger pad and reports the
landing through Flame's own `onCollisionStart`. It runs the physics step as a
Flame component, so the order within a frame is the component tree's.

The README is rewritten around what the bridge does. Nothing in `lib/`
changed.

It asks for `flutter3d` and `flutter3d_physics` `^0.8.1`, which bring the
contact-shadow and folded-cloth fixes; the rest of its `flutter3d_*`
dependencies stay at `^0.8.0`.

## 0.8.0

**Moves with the stack to 0.8.0**, whose `flutter3d_hardware` changes
`PassEncoder.bindTexture` to return `bool` and makes every backend forget its
bindings at `bindPipeline`. Nothing in this package changed.

Its `flutter3d_*` dependencies ask for `^0.8.0`.

## 0.7.1

**Released with the rest of the stack at 0.7.1.** Nothing in this package
changed. The release it resolves against builds from pub.dev again and no
longer crashes Metal on the first unlit draw.

Its `flutter3d_*` dependencies ask for `^0.7.1`, and it asks for `vector_math` ^2.4.3.

## 0.7.0

**A bridge to the Flame 2D game engine.** Flame draws its own layer, flutter3d
draws its own, and `Flutter3dFlameWidget` composites the two in one `Stack`,
Flame's `GameWidget` above flutter3d's `SceneSurface` — the same ordering
`apps/flutter3d_demo_platformer` already uses for a HUD over a bare
`SceneSurface`, and for the same reason: on the web the 3D surface is a
platform view that swallows pointer events, so whatever needs raw input has
to sit above it. A single `BridgeClock` component rides Flame's own game
loop rather than starting a second ticker, so the two engines' frames never
drift apart.

`BridgePlane` is the one place a Flame `Vector2` and a flutter3d `Vector3`
are the same point — a ground plane or a vertical backdrop, chosen once and
shared by every bridged component rather than reinvented per caller.
`Object3dComponent` keeps a Flame `PositionComponent` and a flutter3d
`SceneNode` at the same place on one `BridgePlane`, in whichever direction a
`SyncDirection` names; `ActorComponent` and `RigidBodyComponent` extend it to
carry a `flutter3d_sim` actor's or a `flutter3d_physics` rigid body's own
position across the same seam, and `ActorSystemComponent` centralises the
one `ActorSystem.step` every `ActorComponent` in a game shares.
`CollisionBridge` re-fires flutter3d's collision events as Flame's own,
projecting a 3D contact onto the bridge's plane. `FlameInputBridge` reuses
`flutter3d_game`'s own `Bindings`/`InputState` — a bridged game and a native
one share one rebinding UI and one saved binding file, not two input models.
`CameraSyncController` keeps an orthographic flutter3d camera and Flame's own
2D viewfinder framed the same.
