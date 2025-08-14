// TODO(wolfenrain): in the long run it would be nice of we can make it
// automatically refer to same type of objects to prevent memory leaks

/// {@template resource}
/// A Resource is the base class for any resource typed classes. The primary
/// use case is to be a data container.
/// {@endtemplate}
abstract class Resource<R> {
  R? _resource;
  bool recreateResource = true;

  R createResource();

  R get resource {
    if (recreateResource) {
      _resource = createResource();
      recreateResource = false;
    }
    return _resource!;
  }
}
