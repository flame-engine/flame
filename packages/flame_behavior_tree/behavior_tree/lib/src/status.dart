/// The result of ticking a node.
enum Status() {
  /// The node has completed successfully.
  success,

  /// The node has completed unsuccessfully.
  failure,

  /// The node needs more ticks to complete.
  ///
  /// A running node will be ticked again on the next tick of the tree, unless
  /// one of its ancestors decides to do something else, in which case the node
  /// gets aborted.
  running,
}
