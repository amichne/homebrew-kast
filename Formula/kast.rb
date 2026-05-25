# frozen_string_literal: true

class Kast < Formula
  ARTIFACT_VERSION = "0.7.20"
  DEFAULT_ARTIFACT_ROOT = "https://github.com/amichne"

  def self.artifact_root
    ENV.fetch("HOMEBREW_KAST_ARTIFACT_ROOT", DEFAULT_ARTIFACT_ROOT).chomp("/")
  end

  def self.cli_release_root
    ENV.fetch("HOMEBREW_KAST_CLI_RELEASE_ROOT", "#{artifact_root}/kast-rs/releases/download").chomp("/")
  end

  desc "Workspace control plane for Kotlin analysis daemons"
  homepage "https://github.com/amichne/kast-rs"
  version ARTIFACT_VERSION
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_releases
  end

  on_macos do
    on_intel do
      url "#{cli_release_root}/v#{ARTIFACT_VERSION}/kast-v#{ARTIFACT_VERSION}-macos-x64.zip"
      sha256 "ec817dc53847f3a6c77a54a398f19e346fc5d6ec3486661b405c1a5875407240"
    end

    on_arm do
      url "#{cli_release_root}/v#{ARTIFACT_VERSION}/kast-v#{ARTIFACT_VERSION}-macos-arm64.zip"
      sha256 "71105b46686862fa25b6ee9f4350a8245b4c9c5b801d8c3ddbd0d09c53fb33fe"
    end
  end

  on_linux do
    on_intel do
      url "#{cli_release_root}/v#{ARTIFACT_VERSION}/kast-v#{ARTIFACT_VERSION}-linux-x64.zip"
      sha256 "6a35ffdac5ca12e4f49e490bcd7be02b7860aabc828bff7628aae2d17c62f450"
    end

    on_arm do
      url "#{cli_release_root}/v#{ARTIFACT_VERSION}/kast-v#{ARTIFACT_VERSION}-linux-arm64.zip"
      sha256 "1e3392666a1db9160e91fb942d12a25f46ddf2100c2062283b046432c1e2eadd"
    end
  end

  def install
    bin.install "kast"
  end

  test do
    assert_match "Kast CLI #{version}", shell_output("#{bin}/kast version")
  end
end
