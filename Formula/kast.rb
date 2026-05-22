class Kast < Formula
  desc "Workspace control plane for Kotlin analysis daemons"
  homepage "https://github.com/amichne/kast-rs"
  version "0.7.11"
  license "Apache-2.0"

  on_macos do
    on_intel do
      url "https://github.com/amichne/kast-rs/releases/download/v#{version}/kast-v#{version}-macos-x64.zip"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end

    on_arm do
      url "https://github.com/amichne/kast-rs/releases/download/v#{version}/kast-v#{version}-macos-arm64.zip"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/amichne/kast-rs/releases/download/v#{version}/kast-v#{version}-linux-x64.zip"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end

    on_arm do
      url "https://github.com/amichne/kast-rs/releases/download/v#{version}/kast-v#{version}-linux-arm64.zip"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
  end

  def install
    bin.install "kast"
  end

  test do
    assert_match "Kast CLI", shell_output("#{bin}/kast --help")
  end
end
