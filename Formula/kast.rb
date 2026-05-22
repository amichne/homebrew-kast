class Kast < Formula
  desc "Repo-local control plane for workspace daemons and Kotlin analysis"
  homepage "https://github.com/amichne/kast"
  version "0.7.11"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/amichne/kast/releases/download/v#{version}/kast-v#{version}-macos-arm64.zip"
      sha256 "650c4ee428c70a4f7c60570b5332c202f1cd88fda46203e413756b26b3129fb9"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/amichne/kast/releases/download/v#{version}/kast-v#{version}-linux-x64.zip"
      sha256 "4db120aa4f4a0f6044496c8cc0a093a3e3e8ccd99de34e0968e385bb97398f0f"
    end
  end

  def install
    libexec.install "kast-cli"
    bin.install_symlink libexec/"kast-cli/kast-cli" => "kast"

    metadata = <<~JSON
      {
        "source": "homebrew",
        "version": "#{version}",
        "prefix": "#{prefix}"
      }
    JSON

    (libexec/".install-metadata.json").write metadata
    (libexec/"kast-cli/.install-metadata.json").write metadata
  end

  test do
    assert_match "Kast CLI", shell_output("#{bin}/kast --help")
  end
end
