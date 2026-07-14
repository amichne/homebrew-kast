# frozen_string_literal: true

class Kast < Formula
  ARTIFACT_VERSION = "0.13.0"
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
      sha256 "eba713982147a692e4571100364317a7c889345e5d539b1fef9033c0d4ac8925"
    end

    on_arm do
      url "#{cli_release_root}/v#{ARTIFACT_VERSION}/kast-v#{ARTIFACT_VERSION}-macos-arm64.zip"
      sha256 "a1670132750946958781b3d37afb4db5b6335ae3d90fa4c950da24d92ee6bc43"
    end
  end
  def install
    bin.install "kast"
  end

  def caveats
    <<~EOS
      This formula installs the Kast CLI without changing your IDE profiles.
      To install or repair the version-matched #{PLUGIN_CASK} plugin:

        1. Close IntelliJ IDEA and Android Studio.
        2. Run:
           #{opt_bin}/kast developer machine plugin

      The recommended installer performs both steps for you:
        curl -fsSL https://kast.dev/install.sh | bash
    EOS
  end

  test do
    assert_match "Kast CLI #{version}", shell_output("#{bin}/kast version")
  end
end
