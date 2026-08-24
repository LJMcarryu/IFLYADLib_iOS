from __future__ import annotations

import sys
import tempfile
import unittest
import zipfile
from pathlib import Path


SCRIPTS = Path(__file__).resolve().parents[1] / "scripts"
sys.path.insert(0, str(SCRIPTS))

from prepare_release_consumers import (  # noqa: E402
    VerificationError,
    prepare_cocoapods,
    prepare_swiftpm,
    safe_extract,
)
from release_asset_downloader import MODULE_ASSET_NAMES, expected_assets  # noqa: E402


VERSION = "6.3.0"


def write_zip(path: Path, entries: dict[str, bytes]) -> None:
    with zipfile.ZipFile(path, "w") as archive:
        for name, value in entries.items():
            archive.writestr(name, value)


def create_repository(root: Path) -> None:
    blocks = []
    for module, archive in MODULE_ASSET_NAMES.items():
        blocks.append(
            "        .binaryTarget(\n"
            f'            name: "{module}",\n'
            f'            url: "https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/{VERSION}/{archive}",\n'
            f'            checksum: "{"a" * 64}"\n'
            "        )"
        )
    (root / "Package.swift").write_text(
        "// swift-tools-version:5.9\n"
        "import PackageDescription\n"
        "let package = Package(name: \"IFLYADLib\", targets: [\n"
        + ",\n".join(blocks)
        + "\n])\n",
        encoding="utf-8",
    )
    (root / "spm/Core").mkdir(parents=True)
    (root / "spm/Core/placeholder").write_text("resource", encoding="utf-8")

    consumer = root / ".github/fixtures/swiftpm-consumer"
    (consumer / "Sources/ReleaseConsumer").mkdir(parents=True)
    (consumer / "Package.swift").write_text(
        "// swift-tools-version:5.9\n"
        "import PackageDescription\n"
        "let package = Package(name: \"consumer\", dependencies: [\n"
        "  .package(\n"
        '    url: "https://github.com/LJMcarryu/IFLYADLib_iOS.git",\n'
        '    exact: "6.3.0"\n'
        "  )\n"
        "], targets: [])\n",
        encoding="utf-8",
    )
    (consumer / "Sources/ReleaseConsumer/ReleaseConsumer.swift").write_text(
        "public struct Marker {}\n", encoding="utf-8"
    )

    demo = root / "IFLYADLibSimple"
    demo.mkdir()
    (demo / "Podfile").write_text(
        "platform :ios, '11.0'\n"
        "target 'IFLYADLibSimple' do\n"
        "  pod 'IFLYADLib', :podspec => "
        "'https://raw.githubusercontent.com/LJMcarryu/IFLYADLib_iOS/6.3.0/IFLYADLib.podspec'\n"
        "end\n",
        encoding="utf-8",
    )
    (demo / "project.txt").write_text("demo", encoding="utf-8")
    (root / "IFLYADLib.podspec").write_text("Pod::Spec.new do |s|\nend\n", encoding="utf-8")


def create_assets(root: Path) -> None:
    root.mkdir()
    for module, archive in MODULE_ASSET_NAMES.items():
        write_zip(root / archive, {f"{module}.xcframework/file": module.encode()})
    write_zip(
        root / f"IFLYADLib-modelA-{VERSION}.zip",
        {"LICENSE": b"license", "resources/Core/value": b"resource"},
    )
    (root / "checksums.txt").write_text("checksums\n", encoding="utf-8")
    (root / "binary-targets.remote.swift").write_text("targets\n", encoding="utf-8")
    assert {path.name for path in root.iterdir()} == expected_assets(VERSION)


class PrepareReleaseConsumersTests(unittest.TestCase):
    def test_prepares_local_swiftpm_and_cocoapods_consumers(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            repository = root / "repository"
            repository.mkdir()
            create_repository(repository)
            assets = root / "assets"
            create_assets(assets)

            swiftpm = root / "swiftpm"
            prepare_swiftpm(assets, repository, swiftpm, VERSION)
            sdk_manifest = (swiftpm / "IFLYADLib_iOS/Package.swift").read_text(encoding="utf-8")
            self.assertNotIn("releases/download", sdk_manifest)
            self.assertEqual(sdk_manifest.count("path:"), 7)
            for module in MODULE_ASSET_NAMES:
                self.assertTrue((swiftpm / f"IFLYADLib_iOS/{module}.xcframework/file").is_file())
            consumer_manifest = (swiftpm / "consumer/Package.swift").read_text(encoding="utf-8")
            self.assertIn('.package(path: "../IFLYADLib_iOS")', consumer_manifest)

            cocoapods = root / "cocoapods"
            prepare_cocoapods(assets, repository, cocoapods, VERSION)
            localized = (cocoapods / "IFLYADLibSimple/Podfile").read_text(encoding="utf-8")
            self.assertIn("pod 'IFLYADLib', :path => '../IFLYADLib'", localized)
            self.assertNotIn(":podspec", localized)
            self.assertTrue((cocoapods / "IFLYADLib/IFLYADLib.podspec").is_file())

    def test_safe_extract_rejects_path_traversal(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            archive = root / "bad.zip"
            write_zip(archive, {"../escape": b"bad"})
            with self.assertRaisesRegex(VerificationError, "路径穿越"):
                safe_extract(archive, root / "output")


if __name__ == "__main__":
    unittest.main()
