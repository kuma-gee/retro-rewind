#!/bin/sh

CLIENT_VERSION=$1

# Use the Git hash if no CLIENT_VERSION is given.
if [ -z "$CLIENT_VERSION" ]; then
	# GitLab CI:
	if [ -n "$CI_COMMIT_SHA" ]; then
		CLIENT_VERSION="$CI_COMMIT_SHA"

	# GitHub Actions:
	elif [ -n "$GITHUB_SHA" ]; then
		CLIENT_VERSION="$GITHUB_SHA"
	fi
fi

cat << EOF > godot/addons/debug/Build.gd
class_name Build

const VERSION = '$CLIENT_VERSION'
const SILENT_WOLF_API = '$SILENT_WOLF_API'
const SILENT_WOLF_GAME = '$SILENT_WOLF_GAME'
EOF