# frozen_string_literal: true

class Kast < Formula
  ARTIFACT_VERSION = "0.13.3"
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
      sha256 "82186955f2ad4b48e51501608c3e2b4e0c34227fd08e348eec35033f44fcbace"
    end

    on_arm do
      url "#{cli_release_root}/v#{ARTIFACT_VERSION}/kast-v#{ARTIFACT_VERSION}-macos-arm64.zip"
      sha256 "77d0baf736ccb692370e6fe3630d339d9571896372d27a865621458c2752fda3"
    end
  end
  def install
    bin.install "kast"
  end

  def caveats
    <<~EOS
      Homebrew owns only the Kast CLI. Establish or repair its fail-closed receipt with:
        #{opt_bin}/kast repair --for machine --apply

      Install the matching Kast plugin ZIP from the GitHub release, then add this
      custom plugin repository in JetBrains for subsequent updates:
        https://github.com/amichne/kast/releases/latest/download/updatePlugins.xml

      The recommended installer configures the CLI authority:
        curl -fsSL https://kast.dev/install.sh | bash
    EOS
  end

  test do
    assert_match "Kast CLI #{version}", shell_output("#{bin}/kast version")
  end
end
