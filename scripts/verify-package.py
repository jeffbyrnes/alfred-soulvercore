"""Verify the archive users install, including its executable and framework links."""

import json
import os
from pathlib import Path
import plistlib
import subprocess
import tempfile


archive = Path(".build/SoulverCore.alfredworkflow").resolve()
with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    workflow = root / "workflow"
    subprocess.run(["ditto", "-x", "-k", str(archive), str(workflow)], check=True)
    info = plistlib.loads((workflow / "Info.plist").read_bytes())
    expected_version = os.environ.get("WORKFLOW_VERSION")
    if expected_version:
        assert info["version"] == expected_version.removeprefix("v"), info["version"]

    binary = workflow / "alfred-soulvercore"
    assert os.access(binary, os.X_OK), "Packaged binary is not executable"
    assert (workflow / "SoulverCore.framework/SoulverCore").is_file()
    architectures = subprocess.check_output(["lipo", "-archs", str(binary)], text=True).split()
    assert {"arm64", "x86_64"}.issubset(architectures), architectures
    subprocess.run(["codesign", "--verify", "--strict", str(binary)], check=True)

    env = os.environ.copy()
    env.pop("DYLD_FRAMEWORK_PATH", None)
    env.pop("DYLD_LIBRARY_PATH", None)
    env["alfred_workflow_cache"] = str(root / "cache")
    env["alfred_workflow_data"] = str(root / "data")
    for expression, expected in [("1+1", "2"), ("2 hours in minutes", "120 min")]:
        result = subprocess.run(
            [str(binary), expression], cwd=workflow, env=env,
            capture_output=True, text=True, timeout=10, check=True,
        )
        item = json.loads(result.stdout)["items"][0]
        assert item["title"] == expected and item["arg"] == expected, item
        print(f"{expression} = {expected}")

print(f"Verified {archive.name} (workflow version {info['version']})")
