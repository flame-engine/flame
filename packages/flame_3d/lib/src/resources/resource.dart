import 'package:flutter/foundation.dart';

// TODO(wolfenrain): in the long run it would be nice of we can make it
// automatically refer to same type of objects to prevent memory leaks

/// {@template resource}
/// A Resource is the base class for any resource typed classes. The primary
/// use case is to be a data container.
/// {@endtemplate}
class Resource<R> {
  /// {@macro resource}
  Resource(this._resource);

  /// The resource data.
  R get resource => _resource;
  @protected
  set resource(R resource) => _resource = resource;
  R _resource;
}
