# Small sample game

A sample Flame game showcasing the basic game structure and the use of PositionComponents.

There are a lot more more [examples](../doc/examples) and [docs](../doc).


# Running the sample app

Before running the sample app, be sure you have run `melos bootstrap` from the root
of the `flame` repository.

Then, run the sample app from your IDE or by running `flutter run` from this directory.


# Try using the Flame developer tools when running this app

`package:flame` provides developer tooling as a Flutter DevTools extension. When you
are running an app that depends on `package:flame` from Pub, you will see the Flame
DevTools extension automatically in Flutter DevTools and within your Flutter-supported
IDE.

**However, if you'd like to try the Flame developer tools while running this sample
app, you will need to take one additional step.** Because the sample app depends
on `package:flame` from source (not Pub), the Flame DevTools extension assets will
need to be generated manually. These are normally generated on publish of the `flame`
package, but they are not checked into source control on Github.

To generate the assets for the Flame DevTools extension, run the following from the
root of the `flame` repository:

```sh
melos devtools-build
```

Now, when you run this sample app, you can open Flutter DevTools in your IDE or in
your browser to try out the Flame developer tools.
