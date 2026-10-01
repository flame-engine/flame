import 'package:flame/components.dart';

import 'package:flame_flutter3d/src/host/has_fixed_step.dart';
import 'package:flame_flutter3d/src/world/cell_grid_component.dart';

/// Which way a [GridMover] goes, as the screen sees it: up is towards the
/// top, Flame's `y` falling.
enum GridHeading {
  none(0, 0),
  up(0, -1),
  down(0, 1),
  left(-1, 0),
  right(1, 0);

  const GridHeading(this.dx, this.dy);

  final int dx;
  final int dy;

  /// The way back.
  GridHeading get opposite => switch (this) {
    none => none,
    up => down,
    down => up,
    left => right,
    right => left,
  };
}

/// Moves the component it is added to from the middle of one cell of a
/// [CellGridComponent] to the middle of the next: Pac-Man in his maze, a
/// ghost, a digger, a cycle leaving its trail.
///
/// **The turn waits for the junction.** A maze game is played by asking for
/// a turn before the corner: [wanted] is the way the player asks for, kept
/// until a cell's middle where that way is open, while the mover goes on in
/// [heading]. A turn back the way it came is taken at once, between cells,
/// as the arcade's did. At a wall with no open way asked for, it stops.
///
/// Open is not a cell of the grid, unless [passable] says otherwise: the
/// blocks are the walls. With [wraps], a way off one edge comes in at the
/// other, the tunnel at the sides of the maze.
///
/// **A behaviour, as Flame's are.** Added as a child of what it moves, a
/// `PositionComponent` sharing a parent with [grid]. It moves in the game's
/// fixed steps when the game has `HasFixedStep`, and in frames otherwise;
/// Flame's effects and hitboxes on what it moves go on working, and
/// [onArrive] is told each middle of a cell reached, for a dot to be eaten.
class GridMover extends Component with FixedStepUpdate {
  GridMover({
    required this.grid,
    required this.speed,
    this.passable,
    this.wraps = false,
    this.onArrive,
  });

  /// The grid it moves on.
  final CellGridComponent grid;

  /// Metres a second, read every step.
  double speed;

  /// Whether a cell can be entered; a cell of the grid that is not there,
  /// unless given.
  final bool Function(int column, int row)? passable;

  /// Whether a way off one edge comes in at the other.
  final bool wraps;

  /// Told the cell whose middle has just been reached.
  final void Function(int column, int row)? onArrive;

  /// The way it is going; none while it stands.
  GridHeading heading = GridHeading.none;

  /// The way asked for, kept until it can be taken.
  GridHeading wanted = GridHeading.none;

  int _column = 0;
  int _row = 0;
  bool _stepped = false;

  /// The cell it left last, or stands in.
  (int, int) get cell => (_column, _row);

  PositionComponent get _body => parent! as PositionComponent;

  /// Stood in the middle of the cell its component is in.
  @override
  void onMount() {
    super.onMount();
    _stepped = findGame() is HasFixedStep;
    final (column, row) = grid.cellAt(_body.absolutePosition);
    _column = column;
    _row = row;
    _body.position.setFrom(grid.centreOf(column, row));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_stepped) {
      _advance(dt);
    }
  }

  @override
  void fixedUpdate(double step) => _advance(step);

  (int, int)? _wrapped(int column, int row) {
    final columns = grid.grid.columns;
    final rows = grid.grid.rows;
    if (wraps) {
      return (column % columns, row % rows);
    }
    if (column < 0 || row < 0 || column >= columns || row >= rows) {
      return null;
    }
    return (column, row);
  }

  bool _open(GridHeading way) {
    if (way == GridHeading.none) {
      return false;
    }
    final next = _wrapped(_column + way.dx, _row + way.dy);
    if (next == null) {
      return false;
    }
    final (c, r) = next;
    return passable?.call(c, r) ?? !grid.grid.isAlive(c, r);
  }

  void _advance(double dt) {
    var left = speed * dt;
    final at = _body.position;
    // A turn back is taken where it stands: the cell ahead becomes the one
    // it left.
    if (heading != GridHeading.none && wanted == heading.opposite) {
      _column += heading.dx;
      _row += heading.dy;
      heading = wanted;
    }
    for (var guard = 0; guard < 64 && left > 0.0; guard++) {
      final middle = grid.centreOf(_column, _row);
      if (at.x == middle.x && at.y == middle.y) {
        if (wanted != GridHeading.none && _open(wanted)) {
          heading = wanted;
        } else if (!_open(heading)) {
          heading = GridHeading.none;
        }
        if (heading == GridHeading.none) {
          return;
        }
      }
      final target = grid.centreOf(_column + heading.dx, _row + heading.dy);
      final gap = at.distanceTo(target);
      if (gap > left) {
        at.add((target - at)..scale(left / gap));
        return;
      }
      left -= gap;
      final (c, r) = _wrapped(_column + heading.dx, _row + heading.dy)!;
      _column = c;
      _row = r;
      at.setFrom(grid.centreOf(c, r));
      onArrive?.call(c, r);
    }
  }
}
