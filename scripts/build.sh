#!/usr/bin/env bash

# run this first time:
# flutter update-packages

flutter analyze --flutter-repo
flutter format .
flutter test
