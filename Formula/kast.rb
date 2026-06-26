# frozen_string_literal: true

class Kast < Formula
  ARTIFACT_VERSION = "0.11.0"
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
      sha256 "0083c420d49ba124d23941610c27d93e2b01468de038ac0024875281c2b49f32"
    end

    on_arm do
      url "#{cli_release_root}/v#{ARTIFACT_VERSION}/kast-v#{ARTIFACT_VERSION}-macos-arm64.zip"
      sha256 "d22020782f8f3f4c20e3c6af5f097e5e496ae2ae9ea5e07edfe3613ce5a62981"
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
