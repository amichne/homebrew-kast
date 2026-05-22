class Kast < Formula
  desc "Repo-local control plane for workspace daemons and Kotlin analysis"
  homepage "https://github.com/amichne/kast"
  version "0.7.10"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/amichne/kast/releases/download/v#{version}/kast-v#{version}-macos-arm64.zip"
      sha256 "a348e4932a4f9aaaa55df61fcb175eb6f79df5bd5ba8fe1ecc3526396e4178ca"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/amichne/kast/releases/download/v#{version}/kast-v#{version}-linux-x64.zip"
      sha256 "a9532dcf4d98d395bc90001607de424af8fe0f36cff05479c8584e6f0025e7a3"
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
