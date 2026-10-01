"""Fixture mutations exercise the validator without touching the real project."""
import plistlib
from pathlib import Path
import tempfile
import unittest

from validate_runtime_assets import validate


SWIFT = '''
private enum Constants {
    static let parallaxLayers = [
        ParallaxLayerDefinition(name: "background", subdirectory: "Assets/backgrounds", speed: 1)
    ]
    static let upgrades = [UpgradeDefinition(medallionName: "medallion")]
}
private func loadTextures() {
    let player = texture(named: "player", extension: "png", subdirectory: "Assets/sprites")
    let upgrade = texture(named: definition.medallionName, extension: "png", subdirectory: "Assets/ui")
}
private func setupBackground() {
    let background = texture(named: definition.name, extension: "png", subdirectory: definition.subdirectory)
}
private func texture(named name: String) {
    Bundle.main.url(forResource: name)
}
private enum AudioCue: CaseIterable {
    case menu
    var file: (name: String, extension: String) {
        switch self {
        case .menu: return ("Menu music", "mp3")
        }
    }
}
private func audio() { Bundle.main.url(forResource: file.name) }
'''

ASSETS = ["sprites/player.png", "backgrounds/background.png", "ui/medallion.png", "audio/Menu music.mp3"]
METADATA = {"CFBundleIdentifier": "com.example.fixture", "CFBundleShortVersionString": "1.1", "CFBundleVersion": "15"}
PRIVACY = {"NSPrivacyAccessedAPITypes": [], "NSPrivacyTracking": False}


class ValidatorTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.native = self.root / "native-ios"
        self.source = self.native / "BloodstreamDefenderSpriteKit"
        self.source.mkdir(parents=True)
        (self.source / "GameScene.swift").write_text(SWIFT)
        project = self.native / "BloodstreamDefenderSpriteKit.xcodeproj"
        project.mkdir()
        (project / "project.pbxproj").write_text('PRODUCT_BUNDLE_IDENTIFIER = com.example.fixture;\nMARKETING_VERSION = 1.1;\nCURRENT_PROJECT_VERSION = 15;\n')
        self.app = self.root / "Fixture.app"
        self.app.mkdir()
        for location in (self.source, self.app):
            (location / "PrivacyInfo.xcprivacy").write_bytes(plistlib.dumps(PRIVACY))
            for asset in ASSETS:
                path = location / "Assets" / asset
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_bytes(b"fixture")
        (self.app / "Info.plist").write_bytes(plistlib.dumps(METADATA))

    def check(self):
        return validate(self.root, [self.app])

    def test_valid_source_and_bundle(self):
        report = self.check()
        self.assertTrue(report["passed"], report)
        self.assertEqual(report["source"]["file_count"], 4)
        self.assertTrue(validate(self.native)["passed"])

    def test_extra_source_resource(self):
        (self.source / "Assets/source-art.png").write_bytes(b"extra")
        report = self.check()
        self.assertFalse(report["passed"])
        self.assertEqual(report["source"]["unexpected"], ["source-art.png"])

    def test_missing_source_resource(self):
        (self.source / "Assets" / ASSETS[0]).unlink()
        report = self.check()
        self.assertFalse(report["passed"])
        self.assertEqual(report["source"]["missing"], [ASSETS[0]])

    def test_extra_built_import_metadata(self):
        (self.app / "Assets/player.png.import").write_bytes(b"metadata")
        report = self.check()
        self.assertFalse(report["passed"])
        self.assertEqual(report["bundles"][0]["assets"]["unexpected"], ["player.png.import"])

    def test_missing_built_resource(self):
        (self.app / "Assets" / ASSETS[1]).unlink()
        report = self.check()
        self.assertFalse(report["passed"])
        self.assertEqual(report["bundles"][0]["assets"]["missing"], [ASSETS[1]])

    def test_absent_built_privacy(self):
        (self.app / "PrivacyInfo.xcprivacy").unlink()
        report = self.check()
        self.assertFalse(report["passed"])
        self.assertIn("PrivacyInfo.xcprivacy", str(report["bundles"][0]["errors"]))

    def test_changed_built_privacy(self):
        (self.app / "PrivacyInfo.xcprivacy").write_bytes(plistlib.dumps({**PRIVACY, "NSPrivacyTracking": True}))
        self.assertFalse(self.check()["passed"])

    def test_stale_bundle_version(self):
        (self.app / "Info.plist").write_bytes(plistlib.dumps({**METADATA, "CFBundleVersion": "1"}))
        report = self.check()
        self.assertFalse(report["passed"])
        self.assertIn("CFBundleVersion", str(report["bundles"][0]["errors"]))

    def test_dynamic_loader_drift_fails_closed(self):
        (self.source / "GameScene.swift").write_text(SWIFT.replace('named: "player"', 'named: newDynamicName'))
        report = self.check()
        self.assertFalse(report["passed"])
        self.assertIn("Unrecognized texture load", str(report["errors"]))

    def test_unmapped_audio_case_fails_closed(self):
        (self.source / "GameScene.swift").write_text(SWIFT.replace("    case menu\n", "    case menu\n    case boss\n"))
        report = self.check()
        self.assertFalse(report["passed"])
        self.assertIn("every enum case", str(report["errors"]))

    def test_resource_symlink_rejected(self):
        resource = self.source / "Assets" / ASSETS[0]
        resource.unlink()
        resource.symlink_to(self.app / "Assets" / ASSETS[0])
        report = self.check()
        self.assertFalse(report["passed"])
        self.assertIn("Symlink", str(report["errors"]))


if __name__ == "__main__":
    unittest.main()
