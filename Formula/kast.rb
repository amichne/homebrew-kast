# frozen_string_literal: true

class Kast < Formula
  ARTIFACT_VERSION = "0.7.22"
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
      sha256 "186f9e4959228371a7548ce722c915cdc888e45e2835dea53f1ac4113ebc46b0"
    end

    on_arm do
      url "#{cli_release_root}/v#{ARTIFACT_VERSION}/kast-v#{ARTIFACT_VERSION}-macos-arm64.zip"
      sha256 "1be7f87daaf4efd4f0bd6b55de02fbc728240848b544ac31b00ae1e00444bc5e"
    end
  end

  on_linux do
    on_intel do
      url "#{cli_release_root}/v#{ARTIFACT_VERSION}/kast-v#{ARTIFACT_VERSION}-linux-x64.zip"
      sha256 "51bbea70a0768dc58c3fc6c847bed8f9a999b1556f71f98fb1bd550e5210a092"
    end

    on_arm do
      url "#{cli_release_root}/v#{ARTIFACT_VERSION}/kast-v#{ARTIFACT_VERSION}-linux-arm64.zip"
      sha256 "05b38c2e88ca6803c3eb5819557f30cb16856a9773edf58cde71452ca4b1090e"
    end
  end

  def install
    bin.install "kast"
  end

  test do
    assert_match "Kast CLI #{version}", shell_output("#{bin}/kast version")
  end
end
