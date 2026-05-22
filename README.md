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

The formulas are updated by `repository_dispatch` from the Rust CLI and Kast
plugin release workflows after release assets and `SHA256SUMS` are published.
