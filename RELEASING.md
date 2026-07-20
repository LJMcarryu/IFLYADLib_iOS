# 发版手册（维护者）

> 本仓库 `IFLYADLib_iOS` 是**对外分发仓**：只放分发清单、文档、示例，二进制托管在 GitHub Releases。
> SDK 源码与构建脚本在**内部私有源码仓**（不在本仓）。

## 仓库角色

| 仓库 | 内容 |
| --- | --- |
| 内部私有源码仓 | OC 源码、单元测试、构建脚本（`build-xcframework.sh` / `build-model-a.sh` / `split-resources.sh` / `package-model-a-release.sh`） |
| 本公开仓 `IFLYADLib_iOS` | `Package.swift`（SPM）、`IFLYADLib.podspec`（CocoaPods）、README/文档、示例工程；GitHub Releases 托管 xcframework 二进制 |

## 模型 A 发版流程

1. **内部仓构建产物**：在私有源码仓依次运行 `scripts/build-xcframework.sh --variant Full`、`scripts/build-model-a.sh` 和 `scripts/split-resources.sh`，生成 Full 的 device + simulator 切片、7 个按 `.o` 分区的模块 xcframework，以及 Core / VideoUI / Reward 三域资源。新版本必须对 Full 与 7 个模块执行 `scripts/verify-ios11-compatibility.sh --artifact <XCFramework>`，确认最低系统和切片架构满足 iOS 11 发布基线。
2. **打包 + 算校验和**：
   ```bash
   scripts/package-model-a-release.sh \
     --version <版本> \
     --base-url https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/<版本>
   ```
   产出：7 个单模块 `IFLYAd<模块>.xcframework.zip`、合并 `IFLYADLib-modelA-<版本>.zip`（含全部 xcframework + 三域资源 + `LICENSE` + 隐私清单）、`checksums.txt`、`binary-targets.remote.swift`。
3. **更新本公开仓清单并提交**：
   - `Package.swift`：平台保持 `.iOS("11.0")`，7 个 `binaryTarget` 的 `url` / `checksum` 依 `checksums.txt`；
   - `IFLYADLib.podspec`：平台保持 iOS 11.0，`s.version` 与 `s.source(:http)` 指向新版本合并 zip；
   - README、CHANGELOG 与示例工程 Podfile/Xcode deployment target 同步版本和 iOS 11 最低系统；
   - `swift package dump-package` 解析通过后提交、推送。
4. **建 GitHub Release**：tag = `<版本>`（**无 `v` 前缀**，与历史一致），target 指向上一步的提交；上传 8 个资产（7 单模块 zip + 1 合并 zip）。
5. **发版后校验**：
   - `pod cache clean IFLYADLib --all` 后 `pod spec lint IFLYADLib.podspec`，并构建示例 workspace；
   - 匿名 `curl` 下载任一资产，`shasum -a 256` 与 `Package.swift` 中 checksum 比对一致；
   - （CI 也会做以上 checksum 比对，见 `.github/workflows/ci.yml`）。
6. **（可选）发布到 CocoaPods 官方 trunk**：`pod trunk push IFLYADLib.podspec`。需 owner 的 trunk 会话（owner：`LJMcarryu`、`jmliu6`）。push 后 `pod 'IFLYADLib', '<版本>'` 可零配置使用。

## 注意事项

- **不要重打已上传的 zip**——内容变了 SPM checksum 就变，会让已下载者校验失败；换版本一律另起新 tag。
- Release 的 tag 必须指向**已含新 `Package.swift`** 的提交，否则 SPM 消费方会解析到旧清单。
- 隐私清单 `PrivacyInfo.xcprivacy` 必须随 `Core` 资源进合并 zip（静态库不能内嵌到 Mach-O）。
- 版本号需四处一致：`Package.swift` 的 URL、podspec 的 version 与 source、Release tag、合并 zip 文件名；最低系统在 Package、podspec、示例 Podfile/Xcode 工程和二进制 load command 中保持 iOS 11.0。
- 公开仓为私有源码仓的分发面，**不接受外部代码 PR**；版本只能由维护者经上述流程发布。
