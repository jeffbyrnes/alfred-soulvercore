# Alfred SoulverCore

Use the keyword "c" (for "calculate") to start writing SoulverCore expressions.

[SoulverCore](https://github.com/soulverteam/SoulverCore) from [Soulver](https://soulver.app). SoulverCore icon from [Matthew Skiles](http://matthewskiles.com/).

Run `./scripts/build.sh` to build a universal workflow with the Xcode Swift toolchain.
Open `.build/SoulverCore.alfredworkflow` to install it in Alfred.

For a terminal smoke test, run `.build/workflow/alfred-soulvercore '1+1'`.
Outside Alfred, cache and data files use the `design.precioso.alfred-soulvercore`
directory under the user's Caches and Application Support folders. Alfred's
`alfred_workflow_cache` and `alfred_workflow_data` paths take precedence when set.

Currency refresh failures are logged to stderr. Calculations still return Alfred
JSON using cached or bundled rates; these rates may be outdated. Startup waits at
most five seconds for the refresh callback.

Pushes to `main` and pull requests build and verify the packaged workflow, then
save it as an Actions artifact.

To publish a release, push a version tag such as `v1.0.2`:

```sh
git tag -a v1.0.2 -m "Release v1.0.2"
git push origin v1.0.2
```

The release action builds a universal workflow on macOS, sets its internal version
from the tag, and verifies the extracted archive before creating a GitHub release
with generated notes and `SoulverCore.alfredworkflow` attached. Tags with a hyphen,
such as `v1.0.2-beta.1`, produce prereleases. The action uses GitHub's built-in
token; no additional secret is required.

Run `python3 scripts/verify-package.py` to verify a local build. Set
`WORKFLOW_VERSION=v1.0.2` when running the build and verification scripts to test
version stamping locally.
