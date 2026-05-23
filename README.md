# homebrew-kast

Homebrew tap for [Kast](https://github.com/amichne/kast).

```bash
brew tap amichne/kast
brew install kast
brew install kast-plugin
```

`kast` installs the platform-specific Rust CLI asset from `amichne/kast-rs`.
`kast-plugin` installs the IDEA plugin bundle from `amichne/kast` as a cask and
links it into the newest local IntelliJ IDEA profile it can find. Restart
IntelliJ IDEA after installation or upgrade so the IDE reloads its plugins.

If your JetBrains config directory is somewhere else, point the cask at it:

```bash
KAST_JETBRAINS_CONFIG_ROOT="$HOME/Library/Application Support/JetBrains" brew reinstall kast-plugin
```

The CLI formula does not install the standalone JVM backend or a
Homebrew-managed JDK; use Kast's installer flow when you explicitly need the
standalone backend.

## Enterprise mirrors

The package files default to GitHub release assets, but the release host is
resolved at install time. To use the same tap against an internal Artifactory mirror,
mirror the release tree under one root and set:

```bash
export HOMEBREW_KAST_ARTIFACT_ROOT="https://artifactory.example.com/artifactory/kast-releases"
brew install amichne/kast/kast
brew install amichne/kast/kast-plugin
```

The shared mirror root must expose the same repository-shaped paths:

```text
${HOMEBREW_KAST_ARTIFACT_ROOT}/kast-rs/releases/download/v0.7.14/kast-v0.7.14-macos-arm64.zip
${HOMEBREW_KAST_ARTIFACT_ROOT}/kast/releases/download/v0.7.14/kast-intellij-v0.7.14.zip
```

If your enterprise artifact layout separates the CLI and plugin roots, set the
component-specific roots instead:

```bash
export HOMEBREW_KAST_CLI_RELEASE_ROOT="https://artifactory.example.com/artifactory/kast-cli"
export HOMEBREW_KAST_PLUGIN_RELEASE_ROOT="https://artifactory.example.com/artifactory/kast-plugin"
```

Those roots should point at the directory that contains each `vX.Y.Z` release
directory. Checksums remain pinned in the tap, so mirrored artifacts must be
byte-for-byte copies of the published release assets.

The Homebrew package files are updated atomically by `repository_dispatch` after
the Rust CLI and IntelliJ plugin release assets are both published. A dispatch
must carry one shared version plus all CLI and plugin checksums; the tap rejects
partial component updates so `kast` and `kast-plugin` cannot drift.

To publish from the tap, run the `Publish Aligned Release` workflow with a single
stable version such as `v0.7.12`. The workflow creates that tag in both
`amichne/kast-rs` and `amichne/kast` when needed, waits for both release
workflows, verifies the CLI and IntelliJ plugin artifacts report the same
version, then pushes the Homebrew formula and cask updates in one commit. It requires a
`RELEASE_ORCHESTRATION_TOKEN` secret with write access to both upstream repos and
this tap.
