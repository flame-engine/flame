enum Overflow {
  /// Any content that doesn't fit into the document box will be clipped.
  hidden,

  /// If there is any content that doesn't fit into the document box, it will
  /// be removed, and an "ellipsis" symbol added at the end to indicate that
  /// some content was truncated.
  ellipsis,

  /// The height of the document box will be automatically extended to
  /// accommodate any content that wouldn't fit otherwise. Under this mode the
  /// `height` property is treated as "min-height".
  expand,

  /// Any content that doesn't fit into the document box will be moved onto the
  /// next one or more pages.
  paginate,
}
