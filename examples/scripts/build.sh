#!/bin/bash -e

# run this first time:
# flutter update-packages

flutter analyze --flutter-repo
flutter format .
flutter test
