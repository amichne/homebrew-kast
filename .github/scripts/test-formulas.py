#!/usr/bin/env python3
from pathlib import Path


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(f"error: {message}")


root = Path(__file__).resolve().parents[2]
kast_formula = root / "Formula" / "kast.rb"
plugin_formula = root / "Formula" / "kast-plugin.rb"
workflow = root / ".github" / "workflows" / "update-formula.yml"

require(kast_formula.is_file(), "Formula/kast.rb is missing")
require(plugin_formula.is_file(), "Formula/kast-plugin.rb is missing")
require(workflow.is_file(), ".github/workflows/update-formula.yml is missing")

kast = kast_formula.read_text(encoding="utf-8")
plugin = plugin_formula.read_text(encoding="utf-8")
update = workflow.read_text(encoding="utf-8")

require("github.com/amichne/kast-rs/releases" in kast, "kast formula must install Rust CLI assets from kast-rs")
require('bin.install "kast"' in kast, "kast formula must install the single Rust binary directly")
require("libexec.install \"kast-cli\"" not in kast, "kast formula must not install the old kast-cli bundle")
require("bin.install_symlink" not in kast, "kast formula must not symlink the old launcher")

require("class KastPlugin < Formula" in plugin, "kast-plugin formula class is missing")
require("github.com/amichne/kast/releases" in plugin, "kast-plugin formula must install plugin assets from kast")
require("kast-intellij-v#{version}.zip" in plugin, "kast-plugin formula must target the IntelliJ plugin asset")

require("github.event.client_payload.component" in update, "update workflow must branch by dispatched component")
require("Formula/kast-plugin.rb" in update, "update workflow must update the plugin formula")

print("Homebrew formula contract test passed")
