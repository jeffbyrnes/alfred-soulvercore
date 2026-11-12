Use the keyword "c" (for "calculate") to start writing SoulverCore expressions.

SoulverCore (https://github.com/soulverteam/SoulverCore) from Soulver
(https://soulver.app). SoulverCore icon from Matthew Skiles
(http://matthewskiles.com/).

Run `./scripts/build.sh` to build a universal workflow with the Xcode Swift toolchain.
Open `.build/SoulverCore.alfredworkflow` to install it in Alfred.

For a terminal smoke test, run `.build/workflow/alfred-soulvercore '1+1'`.
Outside Alfred, cache and data files use the `design.precioso.alfred-soulvercore`
directory under the user's Caches and Application Support folders. Alfred's
`alfred_workflow_cache` and `alfred_workflow_data` paths take precedence when set.

Currency refresh failures are logged to stderr. Calculations still return Alfred
JSON using cached or bundled rates; these rates may be outdated. Startup waits at
most five seconds for the refresh callback.
