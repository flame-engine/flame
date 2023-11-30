# FlameNetworkAssets

`FlameNetworkAssets` is a bridge package focused on providing a solution to fetch, and cache assets
from the network.

The `FlameNetworkAssets` class provides an abstraction that should be extended in order to create
asset specific handler.

By default, the package relies on the `http` package to make http requests, and `path_provider`
to get the place to store the local cache, to use a different approach for those, use the
optional arguments in the constructor.

This package bundles a specific asset handler class for images:

```dart
final networkAssets = FlameNetworkImages();
final playerSprite = await networkAssets.load('https://url.com/image.png');
```

To create a specific asset handler class, you just need to extend the `FlameNetworkAssets` class
and define the `decodeAsset` and `encodeAsset` arguments:

```dart
class FlameNetworkCustomAsset extends FlameNetworkAssets<CustomAsset> {
  FlameNetworkImages({
    super.get,
    super.getAppDirectory,
    super.cacheInMemory,
    super.cacheInStorage,
  }) : super(
          decodeAsset: (bytes) => CustomAsset.decode(bytes),
          encodeAsset: (CustomAsset asset) => asset.encode(),
        );
}
```
