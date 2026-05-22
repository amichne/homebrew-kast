#!/usr/bin/env python3
import os
import re
from pathlib import Path


SHA256_RE = re.compile(r"^[0-9a-f]{64}$")
VERSION_RE = re.compile(r"^v?(\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?)$")
PLUGIN_URL_RE = re.compile(
    r"https://github\.com/amichne/kast/releases/download/v[^/\"]+/kast-intellij-v[^/\"]+\.zip"
)


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(f"error: {message}")


def required_env(name: str) -> str:
    value = os.environ.get(name)
    require(value is not None and value.strip(), f"{name} is required")
    return value.strip()


def required_sha(name: str) -> str:
    value = required_env(name).lower()
    require(SHA256_RE.fullmatch(value) is not None, f"{name} must be a 64-character lowercase sha256")
    require(value != "0" * 64, f"{name} must not be the placeholder sha256")
    return value


def release_version() -> str:
    raw = required_env("VERSION")
    match = VERSION_RE.fullmatch(raw)
    require(match is not None, "VERSION must be a semver release such as v1.2.3")
    return match.group(1)


def replace_version(content: str, version: str) -> str:
    updated, count = re.subn(r'version ".*?"', f'version "{version}"', content)
    require(count == 1, "formula must contain exactly one version stanza")
    return updated


def replace_sha256s(content: str, replacements: list[str], formula_name: str) -> str:
    matches = list(re.finditer(r'sha256 ".*?"', content))
    require(len(matches) == len(replacements), f"{formula_name} must contain exactly {len(replacements)} sha256 stanzas")

    pieces: list[str] = []
    cursor = 0
    for match, replacement in zip(matches, replacements):
        pieces.append(content[cursor:match.start()])
        pieces.append(f'sha256 "{replacement}"')
        cursor = match.end()
    pieces.append(content[cursor:])
    return "".join(pieces)


def replace_plugin_url(content: str, version: str) -> str:
    url = f"https://github.com/amichne/kast/releases/download/v{version}/kast-intellij-v{version}.zip"
    updated, count = PLUGIN_URL_RE.subn(url, content)
    require(count == 1, "Formula/kast-plugin.rb must contain exactly one plugin release URL")
    return updated


def main() -> None:
    root = Path(os.environ.get("KAST_TAP_ROOT", Path(__file__).resolve().parents[2]))
    version = release_version()

    kast_formula = root / "Formula" / "kast.rb"
    plugin_formula = root / "Formula" / "kast-plugin.rb"
    require(kast_formula.is_file(), "Formula/kast.rb is missing")
    require(plugin_formula.is_file(), "Formula/kast-plugin.rb is missing")

    kast = replace_version(kast_formula.read_text(encoding="utf-8"), version)
    kast = replace_sha256s(
        kast,
        [
            required_sha("SHA256_MACOS_X64"),
            required_sha("SHA256_MACOS_ARM64"),
            required_sha("SHA256_LINUX_X64"),
            required_sha("SHA256_LINUX_ARM64"),
        ],
        "Formula/kast.rb",
    )
    kast_formula.write_text(kast, encoding="utf-8")

    plugin = replace_plugin_url(plugin_formula.read_text(encoding="utf-8"), version)
    plugin = replace_sha256s(plugin, [required_sha("SHA256_PLUGIN")], "Formula/kast-plugin.rb")
    plugin_formula.write_text(plugin, encoding="utf-8")


if __name__ == "__main__":
    main()
