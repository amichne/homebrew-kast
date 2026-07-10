# frozen_string_literal: true

class Kast < Formula
  ARTIFACT_VERSION = "0.12.4"
  DEFAULT_ARTIFACT_ROOT = "https://github.com/amichne"
  PLUGIN_CASK = "amichne/kast/kast-plugin"

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
      sha256 "4fd428035d0ff71c87a4c581e93b241e6b0caf85a28fbacf797ebf12f3670345"
    end

    on_arm do
      url "#{cli_release_root}/v#{ARTIFACT_VERSION}/kast-v#{ARTIFACT_VERSION}-macos-arm64.zip"
      sha256 "08219c4351af0c0a81d0cbced628e18258e3bd3e5100674720484297aa59c15f"
    end
  end
  def install
    bin.install "kast"
  end

  def post_install
    ohai "Converging version-coupled Kast IDEA plugin and Homebrew install receipt"
    system bin/"kast", "developer", "machine", "plugin", "--cask-token", PLUGIN_CASK
  end

  test do
    assert_match "Kast CLI #{version}", shell_output("#{bin}/kast version")
  end
end
