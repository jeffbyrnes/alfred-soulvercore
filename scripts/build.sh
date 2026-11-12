#!/bin/bash

set -euxo pipefail

swift build -c release --arch arm64 --arch x86_64
bin_path=$(swift build -c release --arch arm64 --arch x86_64 --show-bin-path)
staging_path=.build/workflow
rm -rf "$staging_path"
mkdir -p "$staging_path"
cp -R Resources/* "$bin_path/alfred-soulvercore" "$bin_path/"*.framework "$staging_path"
if [[ -n "${WORKFLOW_VERSION:-}" ]]; then
  python3 - <<'PY'
import os
import pathlib
import plistlib

path = pathlib.Path(".build/workflow/Info.plist")
info = plistlib.loads(path.read_bytes())
info["version"] = os.environ["WORKFLOW_VERSION"].removeprefix("v")
path.write_bytes(plistlib.dumps(info))
PY
fi
install_name_tool -add_rpath '@executable_path' "$staging_path/alfred-soulvercore"
codesign --force --sign - "$staging_path/alfred-soulvercore"
# Start a fresh archive so removed files cannot survive from an older build.
rm -f .build/SoulverCore.alfredworkflow
cd "$staging_path" && zip -qry ../SoulverCore.alfredworkflow ./*
