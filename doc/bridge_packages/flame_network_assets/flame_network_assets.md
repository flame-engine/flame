# FlameNetworkAssets

`FlameNetworkAssets` is bridge package focused in providing a solution to fetch, and cache assets
from the network.

`FlameNetworkAssets` class provides an abstraction that should be extended in order to create
asset specific handler.

By default, that package relies on the `http` package to make http requests, and `path_provider`
to get the place to store the local cache, to use a different approach for those, check the
optional arguments in constructor in order to customize that.

The package already bundles an specific asset handler class for images:

```dart
final networkAssets = FlameNetworkImages();
final charSprite = await networkAssets.load('https://url.com/image.png');
```

To create an specific asset handler class, you just need to extend the `FlameNetworkAssets` class
and define the `decodeAsset` and `endcodeAsset` arguments:

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
