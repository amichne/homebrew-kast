# frozen_string_literal: true

class Kast < Formula
  ARTIFACT_VERSION = "0.10.7"
  DEFAULT_ARTIFACT_ROOT = "https://github.com/amichne"

  def self.artifact_root
    ENV.fetch("HOMEBREW_KAST_ARTIFACT_ROOT", DEFAULT_ARTIFACT_ROOT).chomp("/")
  end

  def self.cli_release_root
    ENV.fetch("HOMEBREW_KAST_CLI_RELEASE_ROOT", "#{artifact_root}/kast/releases/download").chomp("/")
  end

  desc "Workspace control plane for Kotlin analysis daemons"
  homepage "https://github.com/amichne/kast"
  version ARTIFACT_VERSION
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_releases
  end

  on_macos do
    on_intel do
      url "#{cli_release_root}/v#{ARTIFACT_VERSION}/kast-v#{ARTIFACT_VERSION}-macos-x64.zip"
      sha256 "8f4fcd5b4d43700059e9f7e5c30882cce411a163ccf09dad10946227731afe4d"
    end

    on_arm do
      url "#{cli_release_root}/v#{ARTIFACT_VERSION}/kast-v#{ARTIFACT_VERSION}-macos-arm64.zip"
      sha256 "6eeec98d22dbf1b45b7bbd301966882110bd85c06183f9f4659efd7583d89463"
    end
  end
  def install
    bin.install "kast"
  end

  test do
    assert_match "Kast CLI #{version}", shell_output("#{bin}/kast version")
  end
end
