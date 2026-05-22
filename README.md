# homebrew-kast

Homebrew tap for [Kast](https://github.com/amichne/kast).

```bash
brew tap amichne/kast
brew install kast
```

The formula installs the platform-specific native CLI asset. It does not install
the standalone JVM backend or a Homebrew-managed JDK; use Kast's installer flow
when you explicitly need the standalone backend.

The formula is updated by `repository_dispatch` from the main Kast release
workflow after release assets and `SHA256SUMS` are published.
