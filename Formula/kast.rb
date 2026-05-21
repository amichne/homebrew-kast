class Kast < Formula
  desc "Repo-local control plane for workspace daemons and Kotlin analysis"
  homepage "https://github.com/amichne/kast"
  license "Apache-2.0"
  version "0.7.8"

  on_macos do
    on_arm do
      url "https://github.com/amichne/kast/releases/download/v#{version}/kast-v#{version}-macos-arm64.zip"
      sha256 "d022883d3c50e68bf6f2a4858fd56b0e8cc42b073ad0873884e868c78f5a73b5"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/amichne/kast/releases/download/v#{version}/kast-v#{version}-linux-x64.zip"
      sha256 "46027337bcd3af74dfa5bf9f20a313588b475c52656c9bdcf9d249c7354ada68"
    end
  end

  depends_on "openjdk@21"

  def install
    libexec.install Dir["kast-cli/*"]
    bin.install_symlink libexec/"kast-cli" => "kast"

    (libexec/".install-metadata.json").write <<~JSON
      {
        "source": "homebrew",
        "version": "#{version}",
        "prefix": "#{prefix}"
      }
    JSON
  end

  test do
    assert_match "Kast CLI", shell_output("#{bin}/kast --help")
  end
end
