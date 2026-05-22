# homebrew-kast

Homebrew tap for [Kast](https://github.com/amichne/kast).

```bash
brew tap amichne/kast
brew install kast
brew install kast-plugin
```

`kast` installs the platform-specific Rust CLI asset from `amichne/kast-rs`.
`kast-plugin` installs the IDEA plugin bundle from `amichne/kast`.

The CLI formula does not install the standalone JVM backend or a
Homebrew-managed JDK; use Kast's installer flow when you explicitly need the
standalone backend.

## Enterprise mirrors

The formulas default to GitHub release assets, but the release host is resolved
at install time. To use the same formulas against an internal Artifactory mirror,
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

The formulas are updated atomically by `repository_dispatch` after the Rust CLI
and IntelliJ plugin release assets are both published. A dispatch must carry one
shared version plus all CLI and plugin checksums; the tap rejects partial
component updates so `kast` and `kast-plugin` cannot drift.

To publish from the tap, run the `Publish Aligned Release` workflow with a single
stable version such as `v0.7.12`. The workflow creates that tag in both
`amichne/kast-rs` and `amichne/kast` when needed, waits for both release
workflows, verifies the CLI and IntelliJ plugin artifacts report the same
version, then pushes both Homebrew formula updates in one commit. It requires a
`RELEASE_ORCHESTRATION_TOKEN` secret with write access to both upstream repos and
this tap.
