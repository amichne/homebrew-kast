# frozen_string_literal: true

class Kast < Formula
  ARTIFACT_VERSION = "0.12.7"
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
      sha256 "abd018898a10f2ec2b91b861fed8f1c56c71619a29c0f960153d0b1329be13a4"
    end

    on_arm do
      url "#{cli_release_root}/v#{ARTIFACT_VERSION}/kast-v#{ARTIFACT_VERSION}-macos-arm64.zip"
      sha256 "8b4b6dfc13669318790affe61683a67124dc068652b240b497651aa8458f46b3"
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
