# frozen_string_literal: true

class Kast < Formula
  ARTIFACT_VERSION = "0.10.13"
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
      sha256 "0f199b484ec33631aab5df209ca8f1b46820672fff95ea1c44666ca47dbbd0fb"
    end

    on_arm do
      url "#{cli_release_root}/v#{ARTIFACT_VERSION}/kast-v#{ARTIFACT_VERSION}-macos-arm64.zip"
      sha256 "271e6d11ae28990f173e7f70ca2099a51867d60423779c36298dbe9dea3d3aea"
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
