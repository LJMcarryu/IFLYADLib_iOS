from __future__ import annotations

import importlib.util
import plistlib
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))
from model_a_layout import public_header_glob, uses_modular_frameworks

spec = importlib.util.spec_from_file_location("model_a_equivalence", ROOT / "scripts/verify-model-a-asset-equivalence.py")
equivalence = importlib.util.module_from_spec(spec)
spec.loader.exec_module(equivalence)


def write_framework(root: Path, module: str, version: str) -> None:
    libraries = []
    for identifier in sorted(equivalence.EXPECTED_LIBRARY_IDENTIFIERS):
        modular = uses_modular_frameworks(version)
        library = f"{module}.framework" if modular else f"lib{module}.a"
        item = {"LibraryIdentifier": identifier, "LibraryPath": library,
                "SupportedPlatform": "ios", "SupportedArchitectures": ["arm64"]}
        if "simulator" in identifier:
            item.update({"SupportedArchitectures": ["arm64", "x86_64"], "SupportedPlatformVariant": "simulator"})
        if modular:
            framework = root / identifier / library
            headers = framework / "Headers"
            headers.mkdir(parents=True)
            for header in equivalence.MODULE_HEADERS[module] | {f"{module}.h"}:
                (headers / header).write_text("#import <Foundation/Foundation.h>\n")
            (framework / module).write_bytes(b"!<arch>\n")
            (framework / "Modules").mkdir()
            (framework / "Modules/module.modulemap").write_text(
                f'framework module {module} {{ umbrella header "{module}.h" export * module * {{ export * }} }}\n')
            (framework / "Info.plist").write_bytes(plistlib.dumps({
                "CFBundleExecutable": module, "CFBundleName": module,
                "CFBundlePackageType": "FMWK", "CFBundleShortVersionString": version}))
        else:
            if module != "IFLYAdVideoUI":
                headers = root / identifier / "Headers/IFLYADLib"
                headers.mkdir(parents=True)
                (headers / "IFLYAdTypes.h").write_text("old header\n")
                item["HeadersPath"] = "Headers"
            else:
                (root / identifier).mkdir(parents=True)
            (root / identifier / library).write_bytes(b"!<arch>\n")
        libraries.append(item)
    (root / "Info.plist").write_bytes(plistlib.dumps({"AvailableLibraries": libraries}))
    (root / "_CodeSignature").mkdir()
    (root / "_CodeSignature/CodeResources").write_bytes(b"signature inventory")


class ModelAFrameworkContractTests(unittest.TestCase):
    def test_complete_644_module_inventory_keeps_headerless_video_ui(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            parent = Path(temporary)
            summaries = {}
            for module in equivalence.MODULE_ASSETS:
                root = parent / f"{module}.xcframework"
                write_framework(root, module, "6.4.4")
                summaries[module] = equivalence.validate_xcframework(root, module, "6.4.4")
            self.assertEqual(7, len(summaries))
            self.assertEqual(14, sum(item["binaries"] for item in summaries.values()))
            self.assertEqual(0, summaries["IFLYAdVideoUI"]["headers"])
            self.assertEqual(0, summaries["IFLYAdVideoUI"]["modules"])
            self.assertTrue(all(item["headers"] > 0 for module, item in summaries.items() if module != "IFLYAdVideoUI"))

    def test_legacy_header_exception_does_not_apply_to_other_modules(self) -> None:
        for module in set(equivalence.MODULE_ASSETS) - {"IFLYAdVideoUI"}:
            with self.subTest(module=module), tempfile.TemporaryDirectory() as temporary:
                root = Path(temporary)
                write_framework(root, module, "6.4.4")
                info = plistlib.loads((root / "Info.plist").read_bytes())
                for item in info["AvailableLibraries"]:
                    item.pop("HeadersPath")
                (root / "Info.plist").write_bytes(plistlib.dumps(info))
                with self.assertRaisesRegex(equivalence.AssetValidationError, "缺少 HeadersPath"):
                    equivalence.validate_xcframework(root, module, "6.4.4")

    def test_version_boundary_has_no_format_fallback(self) -> None:
        self.assertFalse(uses_modular_frameworks("6.4.4"))
        self.assertTrue(uses_modular_frameworks("6.4.5"))
        self.assertTrue(uses_modular_frameworks("6.4.10"))
        with self.assertRaises(ValueError):
            uses_modular_frameworks("6.4.5-preview")
        self.assertIn("IFLYAdCore.framework/Headers", public_header_glob("IFLYAdCore", "IFLYAdSDK.h", "6.4.5"))

    def test_each_module_accepts_only_its_versioned_layout(self) -> None:
        for module in equivalence.MODULE_ASSETS:
            for version in ("6.4.4", "6.4.5"):
                with self.subTest(module=module, version=version), tempfile.TemporaryDirectory() as temporary:
                    root = Path(temporary)
                    write_framework(root, module, version)
                    result = equivalence.validate_xcframework(root, module, version)
                    self.assertEqual(2, result["binaries"])
                    with self.assertRaises(equivalence.AssetValidationError):
                        equivalence.validate_xcframework(root, module, "6.4.4" if version == "6.4.5" else "6.4.5")

    def test_framework_rejects_broken_interface_inventory_and_version(self) -> None:
        for mutation in ("missing-header", "extra-core-header", "wrong-module", "old-import", "wrong-version", "wrong-architecture", "duplicate-slice"):
            with self.subTest(mutation=mutation), tempfile.TemporaryDirectory() as temporary:
                root = Path(temporary)
                write_framework(root, "IFLYAdBanner", "6.4.5")
                framework = root / "ios-arm64/IFLYAdBanner.framework"
                if mutation == "missing-header":
                    (framework / "Headers/IFLYBannerAd.h").unlink()
                elif mutation == "extra-core-header":
                    (framework / "Headers/IFLYAdTypes.h").write_text("duplicate Core type")
                elif mutation == "wrong-module":
                    (framework / "Modules/module.modulemap").write_text("framework module IFLYADLib {}")
                elif mutation == "old-import":
                    (framework / "Headers/IFLYBannerAd.h").write_text('#import <IFLYADLib/IFLYAdBase.h>')
                elif mutation == "wrong-version":
                    info = plistlib.loads((framework / "Info.plist").read_bytes())
                    info["CFBundleShortVersionString"] = "6.4.4"
                    (framework / "Info.plist").write_bytes(plistlib.dumps(info))
                else:
                    info = plistlib.loads((root / "Info.plist").read_bytes())
                    if mutation == "wrong-architecture":
                        info["AvailableLibraries"][0]["SupportedArchitectures"] = ["x86_64"]
                    else:
                        info["AvailableLibraries"].append(info["AvailableLibraries"][0])
                    (root / "Info.plist").write_bytes(plistlib.dumps(info))
                with self.assertRaises(equivalence.AssetValidationError):
                    equivalence.validate_xcframework(root, "IFLYAdBanner", "6.4.5")


if __name__ == "__main__":
    unittest.main()
