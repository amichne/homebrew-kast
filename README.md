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
