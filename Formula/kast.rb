# frozen_string_literal: true

class Kast < Formula
  ARTIFACT_VERSION = "0.11.1"
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
      sha256 "19317bac94741027f517f84a1cfbce7abe9f4904d399fab90c27dce3478b45a9"
    end

    on_arm do
      url "#{cli_release_root}/v#{ARTIFACT_VERSION}/kast-v#{ARTIFACT_VERSION}-macos-arm64.zip"
      sha256 "6f9bf8c9d105b88ba24c070baebb21b99c3b1008e6a97d22f9fb0289b2b236f4"
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
