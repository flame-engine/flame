class FlameAnimationController {
  FlameAnimationController({
    bool? infinite,
    bool? alternating,
    int? repeatCount,
  })  : assert(infinite == true? repeatCount == null : true,
               'An infinite animation cannot have a repeat count'),
        isInfinite = infinite ?? false,
        isAlternating = alternating ?? false,
        repeatCount = repeatCount ?? 1;

  /// If the effect should first follow the initial curve and then follow the
  /// curve backwards.
  bool isAlternating;

  /// Whether the effect should continue to loop forever.
  bool isInfinite;

  int repeatCount;
}
