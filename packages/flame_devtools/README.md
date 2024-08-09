<!-- markdownlint-disable MD013 -->
<p align="center">
  <a href="https://flame-engine.org">
    <img alt="flame" width="200px" src="https://user-images.githubusercontent.com/6718144/101553774-3bc7b000-39ad-11eb-8a6a-de2daa31bd64.png">
  </a>
</p>

<p align="center">
A Flutter-based game engine.
</p>

<p align="center">
  <a title="Pub" href="https://pub.dev/packages/flame"><img src="https://img.shields.io/pub/v/flame.svg?style=popout"/></a>
  <a title="Test" href="https://github.com/flame-engine/flame/actions?query=workflow%3Acicd+branch%3Amain"><img src="https://github.com/flame-engine/flame/workflows/cicd/badge.svg?branch=main&event=push"/></a>
  <a title="Discord" href="https://discord.gg/pxrBmy4"><img src="https://img.shields.io/discord/509714518008528896.svg"/></a>
  <a title="Melos" href="https://github.com/invertase/melos"><img src="https://img.shields.io/badge/maintained%20with-melos-f700ff.svg"/></a>
  <a title="AI Assist" href="https://app.commanddash.io/agent/flame_engine"><img src="https://img.shields.io/badge/AI-Code%20Assist-EB9FDA.svg"></a>
</p>

---
<!-- markdownlint-enable MD013 -->

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

If you want to run with the devtools extension with the simulated mode for
faster development, you can use `melos devtools-simulator` to start the
simulated environment and run the devtools extension in the browser.
Remember that you have to manually enter the Dart VM Service Connection URI
in the simulated devtools environment.
