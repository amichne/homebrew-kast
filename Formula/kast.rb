# frozen_string_literal: true

class Kast < Formula
  ARTIFACT_VERSION = "0.8.0"
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
      sha256 "3cc00b1533d0fe70e90bc10bd4bfb447fd054a42f3a4f0968754c583790b495b"
    end

    on_arm do
      url "#{cli_release_root}/v#{ARTIFACT_VERSION}/kast-v#{ARTIFACT_VERSION}-macos-arm64.zip"
      sha256 "3ec7d23c47bea1f56f7fa03e30ff3a5ba4f033b6bfd063decbb0e75ef4f7b1a3"
    end
  end

  on_linux do
    on_intel do
      url "#{cli_release_root}/v#{ARTIFACT_VERSION}/kast-v#{ARTIFACT_VERSION}-linux-x64.zip"
      sha256 "6caa3b3f495ad1770d78b7ef14a2898d6485823f88268fff40d100fcd3e0d6bc"
    end

    on_arm do
      url "#{cli_release_root}/v#{ARTIFACT_VERSION}/kast-v#{ARTIFACT_VERSION}-linux-arm64.zip"
      sha256 "9b3c7ff7e24fafdad6f6d96523c9400476cc908ee324b2b7720ef735b47d7b24"
    end
  end

  def install
    bin.install "kast"
  end

  test do
    assert_match "Kast CLI #{version}", shell_output("#{bin}/kast version")
  end
end
