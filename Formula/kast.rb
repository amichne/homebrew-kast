# frozen_string_literal: true

class Kast < Formula
  ARTIFACT_VERSION = "0.12.1"
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
      sha256 "bdc23268b19841b838c6369d0e7f3afb3bf74ff68fb89072b914d0e35a350b00"
    end

    on_arm do
      url "#{cli_release_root}/v#{ARTIFACT_VERSION}/kast-v#{ARTIFACT_VERSION}-macos-arm64.zip"
      sha256 "babfe7721150254896061f0cf8c40c5d63974a2cc1d619bc40020ec9ece2d407"
    end
  end
  def install
    bin.install "kast"
  end

  def post_install
    cask_action = quiet_system("brew", "list", "--cask", "kast-plugin") ? "reinstall" : "install"
    ohai "#{cask_action.capitalize}ing version-coupled Kast IDEA plugin cask"
    system "brew", cask_action, "--cask", PLUGIN_CASK
  end

  test do
    assert_match "Kast CLI #{version}", shell_output("#{bin}/kast version")
  end
end
