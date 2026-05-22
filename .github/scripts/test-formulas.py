#!/usr/bin/env python3
import os
import re
import shutil
import subprocess
import tempfile
from pathlib import Path


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(f"error: {message}")


def formula_version(content: str, label: str) -> str:
    matches = re.findall(r'version "([^"]+)"', content)
    require(len(matches) == 1, f"{label} must contain exactly one version stanza")
    return matches[0]


def plugin_formula_version(content: str, label: str) -> str:
    matches = re.findall(r"kast-intellij-v(\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?)\.zip", content)
    unique = sorted(set(matches))
    require(len(unique) == 1, f"{label} must contain exactly one plugin asset version")
    return unique[0]


root = Path(__file__).resolve().parents[2]
kast_formula = root / "Formula" / "kast.rb"
plugin_formula = root / "Formula" / "kast-plugin.rb"
workflow = root / ".github" / "workflows" / "update-formula.yml"
publish_workflow = root / ".github" / "workflows" / "publish-aligned-release.yml"
updater = root / ".github" / "scripts" / "update-formulas.py"

require(kast_formula.is_file(), "Formula/kast.rb is missing")
require(plugin_formula.is_file(), "Formula/kast-plugin.rb is missing")
require(workflow.is_file(), ".github/workflows/update-formula.yml is missing")
require(publish_workflow.is_file(), ".github/workflows/publish-aligned-release.yml is missing")
require(updater.is_file(), ".github/scripts/update-formulas.py is missing")

kast = kast_formula.read_text(encoding="utf-8")
plugin = plugin_formula.read_text(encoding="utf-8")
update = workflow.read_text(encoding="utf-8")
publish = publish_workflow.read_text(encoding="utf-8")

kast_version = formula_version(kast, "Formula/kast.rb")
plugin_version = plugin_formula_version(plugin, "Formula/kast-plugin.rb")
require(kast_version == plugin_version, f"Formula versions must match: kast={kast_version}, kast-plugin={plugin_version}")

require("github.com/amichne/kast-rs/releases" in kast, "kast formula must install Rust CLI assets from kast-rs")
require('bin.install "kast"' in kast, "kast formula must install the single Rust binary directly")
require('shell_output("#{bin}/kast version")' in kast, "kast formula test must use stable version output")
require("libexec.install \"kast-cli\"" not in kast, "kast formula must not install the old kast-cli bundle")
require("bin.install_symlink" not in kast, "kast formula must not symlink the old launcher")

require("class KastPlugin < Formula" in plugin, "kast-plugin formula class is missing")
require("github.com/amichne/kast/releases" in plugin, "kast-plugin formula must install plugin assets from kast")
require("kast-intellij-v" in plugin, "kast-plugin formula must target the IntelliJ plugin asset")
require('version "' not in plugin, "kast-plugin formula must infer version from the release URL")
require('shell_output(bin/"kast-plugin-path")' in plugin, "kast-plugin test must use Homebrew path objects")

require("Ignore legacy component dispatches" in update, "update workflow must ignore component-only dispatches")
require("Formula/kast-plugin.rb" in update, "update workflow must update the plugin formula")
require("Formula/kast.rb Formula/kast-plugin.rb" in update, "update workflow must stage both formulas together")
require("amichne/kast-rs" in update and "amichne/kast" in update, "update workflow must verify both upstream releases")

require("workflow_dispatch:" in publish, "aligned release workflow must be manually runnable")
require("RELEASE_ORCHESTRATION_TOKEN" in publish, "aligned release workflow must use an explicit orchestration token")
require("ensure_tag amichne/kast-rs" in publish, "aligned release workflow must create the kast-rs tag")
require("ensure_tag amichne/kast " in publish, "aligned release workflow must create the kast tag")
require("backend-intellij-${version}.jar" in publish, "aligned release workflow must inspect plugin versioned output")
require('"$release_dir/cli-linux-x64/kast" version' in publish, "aligned release workflow must inspect CLI version output")
require("git commit -m \"kast ${tag}\"" in publish, "aligned release workflow must publish both formulas")

with tempfile.TemporaryDirectory() as tmp:
    tap_root = Path(tmp)
    shutil.copytree(root / "Formula", tap_root / "Formula")

    env = {
        **os.environ,
        "KAST_TAP_ROOT": str(tap_root),
        "VERSION": "v9.8.7",
        "SHA256_MACOS_X64": "1" * 64,
        "SHA256_MACOS_ARM64": "2" * 64,
        "SHA256_LINUX_X64": "3" * 64,
        "SHA256_LINUX_ARM64": "4" * 64,
        "SHA256_PLUGIN": "5" * 64,
    }
    subprocess.run([str(updater)], env=env, check=True)

    updated_kast = (tap_root / "Formula" / "kast.rb").read_text(encoding="utf-8")
    updated_plugin = (tap_root / "Formula" / "kast-plugin.rb").read_text(encoding="utf-8")
    require(formula_version(updated_kast, "updated Formula/kast.rb") == "9.8.7", "updater must set the CLI version")
    require(plugin_formula_version(updated_plugin, "updated Formula/kast-plugin.rb") == "9.8.7", "updater must set the plugin version")
    require("releases/download/v9.8.7/kast-intellij-v9.8.7.zip" in updated_plugin, "updater must set the plugin URL")
    require('sha256 "' + ("1" * 64) + '"' in updated_kast, "updater must set macOS x64 sha")
    require('sha256 "' + ("2" * 64) + '"' in updated_kast, "updater must set macOS arm64 sha")
    require('sha256 "' + ("3" * 64) + '"' in updated_kast, "updater must set Linux x64 sha")
    require('sha256 "' + ("4" * 64) + '"' in updated_kast, "updater must set Linux arm64 sha")
    require('sha256 "' + ("5" * 64) + '"' in updated_plugin, "updater must set plugin sha")

print("Homebrew formula contract test passed")
