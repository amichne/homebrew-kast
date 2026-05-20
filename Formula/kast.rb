class Kast < Formula
  desc "Repo-local control plane for workspace daemons and Kotlin analysis"
  homepage "https://github.com/amichne/kast"
  license "Apache-2.0"
  version "0.0.1"

  on_macos do
    on_arm do
      url "https://github.com/amichne/kast/releases/download/v#{version}/kast-v#{version}-macos-arm64.zip"
      sha256 "PLACEHOLDER"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/amichne/kast/releases/download/v#{version}/kast-v#{version}-linux-x64.zip"
      sha256 "PLACEHOLDER"
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
