# Contributing Guidelines
If you're interested in contributing to this project, here are a few ways to do so:

## Bug fixes
* If you find a bug, please first report it using [Github issues](https://github.com/flame-engine/flame/issues/new).
* Issues that have already been identified as a bug will be labelled "bug".
* If you'd like to submit a fix for a bug, send a [Pull Request](https://guides.github.com/activities/forking/#making-a-pull-request) from your own fork, also read the [How To](#how-to) and [Development Guidelines](#development-guidelines).
* Include a test that isolates the bug and verifies that it was fixed.
* Also update the example and documentation if necessary.

## New Features
* If you'd like to add a feature to the library that doesn't already exist, feel free to describe the feature in a new [Github issues](https://github.com/flame-engine/flame/issues/new).
* Issues that have been identified as a feature request will be labelled "feature".
* If you'd like to implement the new feature, please wait for feedback from the project maintainers before spending too much time writing the code. In some cases, enhancements may not align well with the project objectives at the time.
* Implement your code and please read the [How To](#how-to) and [Development Guidelines](#development-guidelines).
* Also update the example and documentation where needed.

## Documentation & Miscellaneous
* If you think the documentation could be clearer, or you have an alternative implementation of something that may have more advantages, we would love to hear it.
* As always first file a report in a [Github issues](https://github.com/flame-engine/flame/issues/new).
* Issues that have been identified as a documentation change will be labelled "documentation".
* Implement the changes to the documentation, please read the [How To](#how-to) and [Development Guidelines](#development-guidelines).

# Requirements
For a contribution to be accepted:

* Take note of the [Development Guidelines](#development-guidelines)
* Code must follow existing styling conventions
* Commit message should start with a [issue number](#how-to) and should also be descriptive.

If the contribution doesn't meet these criteria, a maintainer will discuss it with you on the issue. You can still continue to add more commits to the branch you have sent the Pull Request from.

# How To
* First of all [file an bug or feature report](https://github.com/flame-engine/flame/issues/new) on this repository.
* [Fork the project](https://guides.github.com/activities/forking/#fork) on Github
* Clone the forked repository to your local development machine (e.g. `git clone https://github.com/<YOUR_GITHUB_USER>/flame.git`)
* Run `pub get` in the cloned repository to get all the dependencies
* Create a new local branch based on issue number from first step (e.g. `git checkout -b 12-new-feature`)
* Make your changes
* When committing your changes, make sure to start the commit message with `#<issue-number>` (e.g. `git commit -m '#12 - New Feature added'`)
* Push your new branch to your own fork into the same remote branch (e.g. `git push origin 12-new-feature`)
* On Gitlab goto the [pull request page](https://guides.github.com/activities/forking/#making-a-pull-request) on your own fork and create a merge request to this reposistory

# Development Guidelines
* Documentation should be updated.
* Example application should be updated.
* Format the Dart code accordingly.
* Note the [`analysis_options.yaml`](https://github.com/flame-engine/flame/blob/master/analysis_options.yaml) and write code as stated in this file

# Test generating of `dartdoc`
* On local development make sure the `dartdoc` program is mentioned in your `$PATH`
* `dartdoc` can be found here: `<FLUTTER_INSTALL_DIR>/bin/cache/dart-sdk/bin/dartdoc`
* Generate docs with the following command: `dartdoc --no-auto-include-dependencies --quiet`
* Output will be placed into `doc/api/`
