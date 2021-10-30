#!/usr/bin/env bash
# This script manages publishing of Flame and its bridge packages.
#
# Usage: ./publish.sh (no arguments and can be run from any path)
#
# Before publishing this script does the following:
#  * Sets the chosen package's pubspec.yaml file to depend on the newest
#    version of Flame (if it is not Flame itself)
#  * The same as point one for the example of the chosen package
#  * Changes [Next] in CHANGELOG.md to the new version
# After publishing this script does the following:
#  * Changes the packages back to relative paths for the Flame dependency
#  * Creates a branch with the changes
#  * Tags and pushes the latest commit with the new version number
#
# Note: Don't forget to open a PR with the created branch

set -e

yellow=$(tput setaf 3)
bold=$(tput bold)
endcolor=$(tput sgr0)

function set_flame_version() {
  pubspec_file="$1/pubspec.yaml"
  sed -i '/path: .*flame$/d' $pubspec_file
  sed -i "s/flame:/flame: ^$2/" $pubspec_file
}

function set_relative_flame_version() {
  pubspec_file="$1/pubspec.yaml"
  sed -i "s/flame:.*/flame:/" $pubspec_file
  sed -i "/flame:.*/a \ \ \ \ path: $2/flame" $pubspec_file
}

function set_version() {
  pubspec_file="$1/pubspec.yaml"
  changelog_file="$1/CHANGELOG.md"
  current_version=$(grep version $pubspec_file | sed 's/version: //')
  echo -en "\nThe current version is $current_version, enter new version: "
  read -r new_version
  echo -en "Is $yellow$bold$new_version$endcolor the version you want to publish? (y/N) "
  read -r -n 1
  printf "\n"
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    sed -i '/version: "..\/flame\/"/d' $pubspec_file
    sed -i "s/version: $current_version/version: $new_version/" $pubspec_file
    sed -i "s/\[Next\]/\[$new_version\]/" $changelog_file
  else
    set_version $1
  fi
}

echo "Which package do you want to publish?"
echo "-------------------------------------"
packages_dir="$(realpath $(dirname "$0")/../packages/)"
packages=($(find . -type d -name "flame*" -exec basename {} \;))
for i in "${!packages[@]}"; do
  printf "%s\t%s\n" "$(expr $i + 1)" "${packages[$i]}"
done

choice=-1
while [[ "$choice" -gt "${#packages[@]}" || "$choice" -le "0" ]]; do
  read -r -p "Enter a number: " choice
  printf "\n"
done

choice=$((choice-1))
upgrade_package="${packages[$choice]}"
echo -en "You have chosen to publish $yellow$bold$upgrade_package$endcolor, is this correct? (y/N): "
read -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
  printf "\nAborting publish"
  exit 1
fi

flame_version=$(grep version $packages_dir/flame/pubspec.yaml | sed 's/version: //')

upgrade_dir="$packages_dir/$upgrade_package"
cd $upgrade_dir

if [[ ! $upgrade_package = "flame" ]]
then
  sed -i "/publish_to: 'none'/d" $upgrade_dir/pubspec.yaml
  sed -i '/path: "..\/flame\/"/d' $upgrade_dir/pubspec.yaml
  set_flame_version $upgrade_dir $flame_version
  if [ -d "$upgrade_dir/example" ]; then
    set_flame_version $upgrade_dir/example $flame_version
  fi
fi

set_version $upgrade_dir
dart pub publish

if [[ ! $upgrade_package = "flame" ]]
then
  sed -i "/^homepage:.*/a publish_to: 'none'" $upgrade_dir/pubspec.yaml
  set_relative_flame_version $upgrade_dir ".."
  if [ -d "$upgrade_dir/example" ]; then
    set_relative_flame_version $upgrade_dir/example "../.."
  fi
fi

tag="$upgrade_package-$new_version"
branch=publish-$tag
git checkout -B $branch
git commit -a -m "Publish $tag"
git push --set-upstream origin $branch
echo "Pushing tag $tag"
git tag $tag
git push origin $tag
echo -e "Done! Don't forget to open a$yellow$bold pull request$endcolor."
exit 0
