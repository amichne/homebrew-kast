class Kast < Formula
  desc "Repo-local control plane for workspace daemons and Kotlin analysis"
  homepage "https://github.com/amichne/kast"
  license "Apache-2.0"
  version "0.7.4"

  on_macos do
    on_arm do
      url "https://github.com/amichne/kast/releases/download/v#{version}/kast-v#{version}-macos-arm64.zip"
      sha256 "bb045eabbd09188cede0c9466fd4975b1170bb1cabd05c1cea01f9876122b265"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/amichne/kast/releases/download/v#{version}/kast-v#{version}-linux-x64.zip"
      sha256 "985737c1cf0dca964fe4407cff454fe4d0a487eaceaf7cce22f68fcde511eb8b"
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
