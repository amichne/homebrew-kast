# frozen_string_literal: true

class Kast < Formula
  ARTIFACT_VERSION = "0.7.16"
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
      sha256 "b58da254d745d16e60c6975f796a5426f500ad1db1a1b2c3eebfb741b6c90988"
    end

    on_arm do
      url "#{cli_release_root}/v#{ARTIFACT_VERSION}/kast-v#{ARTIFACT_VERSION}-macos-arm64.zip"
      sha256 "ccb42f2f7f27a15b766cc6fbc903e9187baa501c67ece8624e7d8f1da670b4a5"
    end
  end

  on_linux do
    on_intel do
      url "#{cli_release_root}/v#{ARTIFACT_VERSION}/kast-v#{ARTIFACT_VERSION}-linux-x64.zip"
      sha256 "8ff99b506efcd1a45aac2b021a6f889072b992dbfc61b45a640f87b3c5dd80b4"
    end

    on_arm do
      url "#{cli_release_root}/v#{ARTIFACT_VERSION}/kast-v#{ARTIFACT_VERSION}-linux-arm64.zip"
      sha256 "e8eba597ca638a78d84c2363818e5ed61b0b4afa9b141217c4b4255d9928d7cd"
    end
  end

  def install
    bin.install "kast"
  end

  test do
    assert_match "Kast CLI #{version}", shell_output("#{bin}/kast version")
  end
end
