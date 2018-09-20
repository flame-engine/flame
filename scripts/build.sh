#!/bin/bash

dartanalyzer .
flutter format .
flutter test

dartdoc
