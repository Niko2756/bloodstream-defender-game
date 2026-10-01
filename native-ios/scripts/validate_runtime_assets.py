#!/usr/bin/env python3
"""Read-only Bloodstream Defender resource audit; Python 3.9+, standard library.

Run from any directory:
  python3 validate_runtime_assets.py --project-root /path/to/repository
  python3 validate_runtime_assets.py --project-root /path/to/native-ios --app /path/Game.app --json

Checks the current Swift loader's supported grammar, exact Assets inventories,
and optional built bundle metadata/privacy manifest. This is not a signing,
App Store privacy compliance, image-quality, or runtime gameplay test.
No files are modified; JSON output can be redirected by the caller.
"""

import argparse
import json
from pathlib import Path, PurePosixPath
import plistlib
import re
import sys
from xml.parsers.expat import ExpatError


class ValidationError(Exception):
    pass


def require(condition, message):
    if not condition:
        raise ValidationError(message)


def masked_swift(text):
    """Mask comments/string contents, retaining offsets for balanced blocks."""
    token = re.compile(r'"(?:\\.|[^"\\])*"|//[^\n]*|/\*.*?\*/', re.S)
    return token.sub(lambda match: " " * len(match.group()), text)


def block(text, declaration, opener="{", closer="}"):
    mask = masked_swift(text)
    matches = list(re.finditer(declaration, mask))
    require(len(matches) == 1, "Expected one declaration matching: " + declaration)
    start = mask.find(opener, matches[0].end())
    require(start >= 0, "Missing opening delimiter for " + declaration)
    depth = 1
    for i in range(start + 1, len(mask)):
        if mask[i] == opener:
            depth += 1
        elif mask[i] == closer:
            depth -= 1
            if depth == 0:
                return text[start + 1:i]
    raise ValidationError("Unbalanced declaration: " + declaration)


def without_comments(text):
    token = re.compile(r'"(?:\\.|[^"\\])*"|//[^\n]*|/\*.*?\*/', re.S)
    return token.sub(lambda match: match.group() if match.group().startswith('"') else " ", text)


def expected_assets(source):
    code = without_comments(source)
    load = block(code, r"private\s+func\s+loadTextures\s*\(\s*\)")
    calls = re.findall(r"\btexture\s*\(\s*named\s*:\s*([^)]*)\)", load)
    require(calls, "No texture loads parsed")
    expected = set()
    groups = {"direct_textures": 0, "parallax": 0, "medallions": 0, "audio": 0}

    def add(directory, name, extension, group):
        require(directory.startswith("Assets/"), "Resource outside Assets: " + directory)
        relative = f"{directory[7:]}/{name}.{extension}"
        path = PurePosixPath(relative)
        require(not path.is_absolute() and all(p not in ("", ".", "..") for p in relative.split("/")),
                "Unsafe resource path: " + relative)
        require("\\" not in relative and not any(p.startswith(".") for p in path.parts),
                "Unsupported resource name: " + relative)
        require(relative not in expected, "Duplicate resource definition: " + relative)
        expected.add(relative)
        groups[group] += 1

    medallion_call = r'definition\.medallionName\s*,\s*extension:\s*"png"\s*,\s*subdirectory:\s*"Assets/ui"'
    medallion_calls = 0
    for call in calls:
        match = re.fullmatch(r'"([^"\\]+)"\s*,\s*extension:\s*"([^"\\]+)"\s*,\s*subdirectory:\s*"([^"\\]+)"\s*', call)
        if match:
            name, extension, directory = match.groups()
            add(directory, name, extension, "direct_textures")
        elif re.fullmatch(medallion_call + r"\s*", call):
            medallion_calls += 1
        else:
            raise ValidationError("Unrecognized texture load: " + call)
    require(medallion_calls == 1, "Expected exactly one dynamic medallion loader")

    layers = block(code, r"static\s+let\s+parallaxLayers\s*=", "[", "]")
    layer_names = re.findall(r'ParallaxLayerDefinition\s*\(\s*name:\s*"([^"\\]+)"\s*,\s*subdirectory:\s*"([^"\\]+)"\s*,', layers)
    require(layer_names and len(layer_names) == len(re.findall(r"\bParallaxLayerDefinition\s*\(", layers)),
            "Unrecognized parallax definition")
    for name, directory in layer_names:
        add(directory, name, "png", "parallax")

    upgrades = block(code, r"static\s+let\s+upgrades\s*=", "[", "]")
    medallions = re.findall(r'medallionName:\s*"([^"\\]+)"\s*(?=[,)])', upgrades)
    require(medallions and len(medallions) == len(re.findall(r"\bUpgradeDefinition\s*\(", upgrades)),
            "Unrecognized upgrade medallion definition")
    for name in medallions:
        add("Assets/ui", name, "png", "medallions")

    # Any additional texture call must be reviewed, rather than silently omitted.
    all_calls = re.findall(r"(?<!func )\btexture\s*\(\s*named\s*:\s*([^)]*)\)", code)
    background_call = r'definition\.name\s*,\s*extension:\s*"png"\s*,\s*subdirectory:\s*definition\.subdirectory\s*'
    require(len(all_calls) == len(calls) + 1 and sum(bool(re.fullmatch(background_call, c)) for c in all_calls) == 1,
            "Texture calls outside the recognized loaders; update this validator")

    audio = block(code, r"private\s+enum\s+AudioCue\s*:\s*CaseIterable")
    case_prefix = audio[:audio.find("var file:")]
    cases = re.findall(r"\bcase\s+([A-Za-z][A-Za-z0-9_]*)\s*(?=\n|$)", case_prefix)
    require(cases and len(cases) == len(re.findall(r"\bcase\b", case_prefix)), "Unrecognized AudioCue enum cases")
    audio_file = block(audio, r"var\s+file\s*:\s*\(name:\s*String,\s*extension:\s*String\)")
    audio_switch = block(audio_file, r"switch\s+self")
    audio_pattern = re.compile(r'case\s+\.([A-Za-z][A-Za-z0-9_]*)\s*:\s*return\s*\(\s*"([^"\\]+)"\s*,\s*"([^"\\]+)"\s*\)')
    audio_entries = list(audio_pattern.finditer(audio_switch))
    require(not audio_pattern.sub("", audio_switch).strip(), "Unrecognized AudioCue.file switch grammar")
    require(sorted(m.group(1) for m in audio_entries) == sorted(cases), "AudioCue.file does not map every enum case exactly once")
    for match in audio_entries:
        add("Assets/audio", match.group(2), match.group(3), "audio")

    # The app currently has just the texture helper and the audio URL lookup.
    require(len(re.findall(r"\bBundle\.main\.url\s*\(\s*forResource:", code)) == 2,
            "Resource URL loaders changed; update this validator")
    return expected, groups


def inventory(directory, expected):
    require(directory.is_dir(), "Missing Assets directory: " + str(directory))
    files = {}
    for path in directory.rglob("*"):
        require(not path.is_symlink(), "Symlink is not an approved resource: " + str(path))
        if path.is_file():
            files[path.relative_to(directory).as_posix()] = path.stat().st_size
        else:
            require(path.is_dir(), "Nonregular resource: " + str(path))
    actual = set(files)
    return {"path": str(directory), "file_count": len(files), "bytes": sum(files.values()),
            "missing": sorted(expected - actual), "unexpected": sorted(actual - expected),
            "files": dict(sorted(files.items()))}


def read_plist(path):
    require(path.is_file() and not path.is_symlink(), "Missing or unsafe plist: " + str(path))
    try:
        data = plistlib.loads(path.read_bytes())
    except (plistlib.InvalidFileException, ExpatError, ValueError, TypeError, OverflowError) as error:
        raise ValidationError(f"Invalid plist {path}: {error}") from error
    require(isinstance(data, dict), "Plist must be a dictionary: " + str(path))
    return data


def project_metadata(project):
    pbx = (project / "BloodstreamDefenderSpriteKit.xcodeproj/project.pbxproj").read_text()
    names = {"CFBundleIdentifier": "PRODUCT_BUNDLE_IDENTIFIER", "CFBundleShortVersionString": "MARKETING_VERSION", "CFBundleVersion": "CURRENT_PROJECT_VERSION"}
    result = {}
    for key, setting in names.items():
        values = re.findall(r"\b" + setting + r"\s*=\s*([^;]+);", pbx)
        values = [v.strip().strip('"') for v in values]
        require(values and len(set(values)) == 1, "Missing/inconsistent project setting: " + setting)
        require("$(" not in values[0], "Unresolved project setting: " + setting)
        result[key] = values[0]
    return result


def validate(project_root, apps=()):
    root = Path(project_root).expanduser().resolve()
    project = root / "native-ios" if (root / "native-ios/BloodstreamDefenderSpriteKit").is_dir() else root
    app_source = project / "BloodstreamDefenderSpriteKit"
    report = {"project_root": str(project), "passed": False, "errors": [], "bundles": []}
    errors = report["errors"]
    try:
        code = (app_source / "GameScene.swift").read_text()
        expected, groups = expected_assets(code)
        report["expected_count"] = len(expected)
        report["parsed_resource_groups"] = groups
        report["source"] = inventory(app_source / "Assets", expected)
        if report["source"]["missing"] or report["source"]["unexpected"]:
            errors.append("Source Assets inventory does not match runtime references")
        metadata = project_metadata(project)
        report["expected_bundle_metadata"] = metadata
        privacy = read_plist(app_source / "PrivacyInfo.xcprivacy")
        require("NSPrivacyAccessedAPITypes" in privacy and "NSPrivacyTracking" in privacy,
                "Source privacy manifest lacks expected declarations")
        for value in apps:
            app = Path(value).expanduser().resolve()
            bundle = {"path": str(app), "errors": []}
            report["bundles"].append(bundle)
            try:
                require(app.is_dir() and app.suffix == ".app", "Expected built .app directory: " + str(app))
                bundle["assets"] = inventory(app / "Assets", expected)
                if bundle["assets"]["missing"] or bundle["assets"]["unexpected"]:
                    bundle["errors"].append("Built Assets inventory does not match runtime references")
                info = read_plist(app / "Info.plist")
                bundle["metadata"] = {k: info.get(k) for k in metadata}
                bundle["platform"] = info.get("DTPlatformName")
                for key, expected_value in metadata.items():
                    if info.get(key) != expected_value:
                        bundle["errors"].append(f"{key}: expected {expected_value!r}, found {info.get(key)!r}")
                built_privacy = read_plist(app / "PrivacyInfo.xcprivacy")
                require(built_privacy == privacy, "Built privacy manifest differs from source")
                bundle["privacy_manifest_matches"] = True
            except (ValidationError, OSError) as error:
                bundle["errors"].append(str(error))
            if bundle["errors"]:
                errors.append("Built bundle failed: " + str(app))
    except (ValidationError, OSError) as error:
        errors.append(str(error))
    report["passed"] = not errors
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--project-root", type=Path, required=True, help="Repository root or native-ios directory")
    parser.add_argument("--app", action="append", default=[], type=Path, help="Optional built .app; repeat to check multiple bundles")
    parser.add_argument("--json", action="store_true", help="Print full machine-readable inventory")
    args = parser.parse_args()
    report = validate(args.project_root, args.app)
    if args.json:
        print(json.dumps(report, indent=2, sort_keys=True))
    else:
        print("PASS" if report["passed"] else "FAIL")
        for label, item in [("source", report.get("source"))] + [(b["path"], b.get("assets")) for b in report["bundles"]]:
            if item:
                print(f"{label}: {item['file_count']} files, {item['bytes']:,} bytes")
                for key in ("missing", "unexpected"):
                    if item[key]:
                        print(f"  {key}: " + ", ".join(item[key]))
        for error in report["errors"]:
            print("ERROR: " + error)
        for bundle in report["bundles"]:
            for error in bundle["errors"]:
                print("ERROR: " + error)
    return 0 if report["passed"] else 1


if __name__ == "__main__":
    sys.exit(main())
