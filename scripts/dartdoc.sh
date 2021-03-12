#!/usr/bin/env bash

cd packages/flame
flutter pub get
flutter pub run dartdoc --no-auto-include-dependencies --quiet
