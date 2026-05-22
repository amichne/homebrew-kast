# frozen_string_literal: true

class KastPlugin < Formula
  ARTIFACT_VERSION = "0.7.14"
  DEFAULT_ARTIFACT_ROOT = "https://github.com/amichne"

  def self.artifact_root
    ENV.fetch("HOMEBREW_KAST_ARTIFACT_ROOT", DEFAULT_ARTIFACT_ROOT).chomp("/")
  end

  def self.plugin_release_root
    ENV.fetch("HOMEBREW_KAST_PLUGIN_RELEASE_ROOT", "#{artifact_root}/kast/releases/download").chomp("/")
  end

  desc "IntelliJ IDEA plugin bundle for Kast Kotlin analysis"
  homepage "https://github.com/amichne/kast"
  url "#{plugin_release_root}/v#{ARTIFACT_VERSION}/kast-intellij-v#{ARTIFACT_VERSION}.zip"
  sha256 "5b1e3f9c35feaa05956c4af097f9c95bbcd45bd58531676bf1c915c0150cae0f"
  license "Apache-2.0"

  def install
    libexec.install Dir["*"]

    (bin/"kast-plugin-path").write <<~SH
      #!/usr/bin/env bash
      printf '%s\n' "#{libexec}"
    SH
  end

  test do
    assert_path_exists libexec
    assert_match libexec.to_s, shell_output(bin/"kast-plugin-path")
  end
end
