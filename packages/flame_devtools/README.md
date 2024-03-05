# flame_devtools

A DevTools extension for Flame games. To use it you just have to run your
Flame game in debug mode and open the DevTools in your browser, and it should
ask you if you want to add the Flame DevTools extension as a separate tab.


## Development

To run it locally, make sure to run `melos devtools-build` to build the
extension so that it can be loaded in the browser (the build files are not
committed to the repository).

After you have done any changes, make sure to run `melos devtools-build` to
build and copy the changes to `packages/flame/extension/build`.

To develop things from the Flame side, create a new `DevToolsConnector` which
registers the new extension end points so that you can communicate with Flame
from the devtools extension. Don't forget to add the new connector to the
list of connectors in the `DevToolsService` class.
