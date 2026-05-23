#!/usr/bin/env python3
import json
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
    matches = re.findall(r'ARTIFACT_VERSION = "([^"]+)"', content)
    require(len(matches) == 1, f"{label} must contain exactly one artifact version constant")
    return matches[0]


def cask_version(content: str, label: str) -> str:
    matches = re.findall(r'artifact_version = "([^"]+)"', content)
    require(len(matches) == 1, f"{label} must contain exactly one artifact version")
    return matches[0]


root = Path(__file__).resolve().parents[2]
kast_formula = root / "Formula" / "kast.rb"
plugin_cask = root / "Casks" / "kast-plugin.rb"
readme = root / "README.md"
release_state = root / "release-state.json"
release_state_helper = root / ".github" / "scripts" / "release-state.py"
workflow = root / ".github" / "workflows" / "update-formula.yml"
publish_workflow = root / ".github" / "workflows" / "publish-aligned-release.yml"
updater = root / ".github" / "scripts" / "update-formulas.py"

require(kast_formula.is_file(), "Formula/kast.rb is missing")
require(plugin_cask.is_file(), "Casks/kast-plugin.rb is missing")
require(readme.is_file(), "README.md is missing")
require(release_state.is_file(), "release-state.json is missing")
require(release_state_helper.is_file(), ".github/scripts/release-state.py is missing")
require(workflow.is_file(), ".github/workflows/update-formula.yml is missing")
require(publish_workflow.is_file(), ".github/workflows/publish-aligned-release.yml is missing")
require(updater.is_file(), ".github/scripts/update-formulas.py is missing")

kast = kast_formula.read_text(encoding="utf-8")
plugin = plugin_cask.read_text(encoding="utf-8")
docs = readme.read_text(encoding="utf-8")
state = json.loads(release_state.read_text(encoding="utf-8"))
update = workflow.read_text(encoding="utf-8")
publish = publish_workflow.read_text(encoding="utf-8")

kast_version = formula_version(kast, "Formula/kast.rb")
plugin_version = cask_version(plugin, "Casks/kast-plugin.rb")
require(kast_version == plugin_version, f"Package versions must match: kast={kast_version}, kast-plugin={plugin_version}")
require(state.get("schema_version") == 1, "release-state.json schema_version must be 1")
require(
    state.get("current_release") == f"v{kast_version}",
    f"release-state.json must match package version v{kast_version}",
)

release_env = {**os.environ, "KAST_TAP_ROOT": str(root)}
current_release = subprocess.run(
    [str(release_state_helper), "current"],
    env=release_env,
    check=True,
    text=True,
    capture_output=True,
).stdout.strip()
next_release = subprocess.run(
    [str(release_state_helper), "next-patch"],
    env=release_env,
    check=True,
    text=True,
    capture_output=True,
).stdout.strip()
require(current_release == f"v{kast_version}", "release-state helper must report the current tap release")
major, minor, patch = (int(part) for part in kast_version.split("."))
require(next_release == f"v{major}.{minor}.{patch + 1}", "release-state helper must compute the next patch release")

require("brew install amichne/kast/kast" in docs, "README must document direct CLI installation")
require("brew install --cask amichne/kast/kast-plugin" in docs, "README must document direct cask installation")
require("brew tap amichne/kast" in docs, "README must document manual tap installation")
require("brew install --cask kast-plugin" in docs, "README must mark kast-plugin as a cask")
require(
    f"/v{kast_version}/kast-v{kast_version}-macos-arm64.zip" in docs,
    "README mirror CLI example must match the package version",
)
require(
    f"/v{plugin_version}/kast-intellij-v{plugin_version}.zip" in docs,
    "README mirror plugin example must match the package version",
)

require("HOMEBREW_KAST_ARTIFACT_ROOT" in kast, "kast formula must support a shared artifact mirror root")
require("HOMEBREW_KAST_CLI_RELEASE_ROOT" in kast, "kast formula must support a CLI-specific release root")
require("kast-rs/releases/download" in kast, "kast formula must default to the Rust CLI release path")
require('bin.install "kast"' in kast, "kast formula must install the single Rust binary directly")
require('shell_output("#{bin}/kast version")' in kast, "kast formula test must use stable version output")
require("strategy :github_releases" in kast, "kast formula livecheck must ignore unpublished draft tags")
require("libexec.install \"kast-cli\"" not in kast, "kast formula must not install the old kast-cli bundle")
require("bin.install_symlink" not in kast, "kast formula must not symlink the old launcher")

require('cask "kast-plugin"' in plugin, "kast-plugin cask token is missing")
require("HOMEBREW_KAST_ARTIFACT_ROOT" in plugin, "kast-plugin cask must support a shared artifact mirror root")
require("HOMEBREW_KAST_PLUGIN_RELEASE_ROOT" in plugin, "kast-plugin cask must support a plugin-specific release root")
require("kast/releases/download" in plugin, "kast-plugin cask must default to the JVM plugin release path")
require("kast-intellij-v" in plugin, "kast-plugin cask must target the IntelliJ plugin asset")
require("stage_only true" in plugin, "kast-plugin cask must keep the plugin bundle Homebrew-managed")
require("kast-rs/releases" in plugin, "kast-plugin cask livecheck must follow the aligned CLI release")
require("strategy :github_releases" in plugin, "kast-plugin cask livecheck must ignore unpublished draft tags")
require("postflight do" in plugin, "kast-plugin cask must link into IntelliJ after install")
require("uninstall_postflight do" in plugin, "kast-plugin cask must remove IntelliJ links on uninstall")
require("KAST_JETBRAINS_CONFIG_ROOT" in plugin, "kast-plugin cask must support testable JetBrains config roots")
require("IntelliJIdea" in plugin and "IdeaIC" in plugin, "kast-plugin cask must target IntelliJ IDEA config directories")

require("Ignore legacy component dispatches" in update, "update workflow must ignore component-only dispatches")
require("Casks/kast-plugin.rb" in update, "update workflow must update the plugin cask")
require(
    "Formula/kast.rb Casks/kast-plugin.rb README.md release-state.json" in update,
    "update workflow must stage packages, docs, and release state together",
)
require("amichne/kast-rs" in update and "amichne/kast" in update, "update workflow must verify both upstream releases")

require("workflow_dispatch:" in publish, "aligned release workflow must be manually runnable")
require("RELEASE_ORCHESTRATION_TOKEN" in publish, "aligned release workflow must use an explicit orchestration token")
require("release-state.py next-patch" in publish, "aligned release workflow must derive the next patch release from tap state")
require("git/ref/tags" in publish, "aligned release workflow must avoid auto-selecting an occupied upstream tag")
require("ensure_tag amichne/kast-rs" in publish, "aligned release workflow must create the kast-rs tag")
require("ensure_tag amichne/kast " in publish, "aligned release workflow must create the kast tag")
require("backend-intellij-${version}.jar" in publish, "aligned release workflow must inspect plugin versioned output")
require('"$release_dir/cli-linux-x64/kast" version' in publish, "aligned release workflow must inspect CLI version output")
require("git commit -m \"kast ${tag}\"" in publish, "aligned release workflow must publish both packages")
require(
    "Formula/kast.rb Casks/kast-plugin.rb README.md release-state.json" in publish,
    "aligned release workflow must commit package files, docs, and release state together",
)

with tempfile.TemporaryDirectory() as tmp:
    tap_root = Path(tmp)
    shutil.copytree(root / "Formula", tap_root / "Formula")
    shutil.copytree(root / "Casks", tap_root / "Casks")
    shutil.copy2(readme, tap_root / "README.md")
    shutil.copy2(release_state, tap_root / "release-state.json")

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
    updated_plugin = (tap_root / "Casks" / "kast-plugin.rb").read_text(encoding="utf-8")
    updated_docs = (tap_root / "README.md").read_text(encoding="utf-8")
    updated_state = json.loads((tap_root / "release-state.json").read_text(encoding="utf-8"))
    require(formula_version(updated_kast, "updated Formula/kast.rb") == "9.8.7", "updater must set the CLI version")
    require(cask_version(updated_plugin, "updated Casks/kast-plugin.rb") == "9.8.7", "updater must set the plugin version")
    require(updated_state.get("current_release") == "v9.8.7", "updater must set the current release state")
    require("/v9.8.7/kast-v9.8.7-macos-arm64.zip" in updated_docs, "updater must set the README CLI mirror example")
    require("/v9.8.7/kast-intellij-v9.8.7.zip" in updated_docs, "updater must set the README plugin mirror example")
    require("artifact_version = \"9.8.7\"" in updated_plugin, "updater must set the plugin artifact version")
    require('sha256 "' + ("1" * 64) + '"' in updated_kast, "updater must set macOS x64 sha")
    require('sha256 "' + ("2" * 64) + '"' in updated_kast, "updater must set macOS arm64 sha")
    require('sha256 "' + ("3" * 64) + '"' in updated_kast, "updater must set Linux x64 sha")
    require('sha256 "' + ("4" * 64) + '"' in updated_kast, "updater must set Linux arm64 sha")
    require('sha256 "' + ("5" * 64) + '"' in updated_plugin, "updater must set plugin sha")

print("Homebrew package contract test passed")
