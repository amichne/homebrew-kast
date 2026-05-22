class Kast < Formula
  desc "Workspace control plane for Kotlin analysis daemons"
  homepage "https://github.com/amichne/kast-rs"
  version "0.7.14"
  license "Apache-2.0"

  on_macos do
    on_intel do
      url "https://github.com/amichne/kast-rs/releases/download/v#{version}/kast-v#{version}-macos-x64.zip"
      sha256 "b335c31447d5ceeaa3ffb3dde3eb9371b395228db88d9f4215d7f65b43842734"
    end

    on_arm do
      url "https://github.com/amichne/kast-rs/releases/download/v#{version}/kast-v#{version}-macos-arm64.zip"
      sha256 "9393680a6e395e86da782ab51151fcac132eff8d5e5f26ff2e4afe8b1e4446a3"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/amichne/kast-rs/releases/download/v#{version}/kast-v#{version}-linux-x64.zip"
      sha256 "749d18102e6e9ad08a76787949aed1203c89007133e45b78a6abd76fd36cbb2a"
    end

    on_arm do
      url "https://github.com/amichne/kast-rs/releases/download/v#{version}/kast-v#{version}-linux-arm64.zip"
      sha256 "7158f8577a049baff482e6803acfc6f9c4cc0d9ec234cba3a6b3f83e0819282a"
    end
  end

  def install
    bin.install "kast"
  end

  test do
    assert_match "Kast CLI", shell_output("#{bin}/kast --help")
  end
end
