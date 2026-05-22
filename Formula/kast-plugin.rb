class KastPlugin < Formula
  desc "IntelliJ IDEA plugin bundle for Kast Kotlin analysis"
  homepage "https://github.com/amichne/kast"
  url "https://github.com/amichne/kast/releases/download/v#{version}/kast-intellij-v#{version}.zip"
  version "0.7.14"
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
