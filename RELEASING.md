# 发版手册（维护者）

> 本仓库 `IFLYADLib_iOS` 是**对外分发仓**：只放分发清单、文档、示例，二进制托管在 GitHub Releases。
> SDK 源码与构建脚本在**内部私有源码仓**（不在本仓）。

## 当前正式版本

`6.2.0` 于 2026-08-06 正式发布，是当前最新正式版本；正式二进制使用 Xcode 26.2 构建。

正式 tag 必须指向同时包含最终 checksum、`spm/` 资源和正式版本文案的提交；不得只改版本号、复用上一版本 checksum 或覆盖既有 tag 与 Release。

## 仓库角色

| 仓库 | 内容 |
| --- | --- |
| 内部私有源码仓 | OC 源码、单元测试、构建脚本（`build-xcframework.sh` / `build-model-a.sh` / `split-resources.sh` / `package-model-a-release.sh`） |
| 本公开仓 `IFLYADLib_iOS` | `Package.swift`（SPM）、`IFLYADLib.podspec`（CocoaPods）、README/文档、示例工程；GitHub Releases 托管 xcframework 二进制 |

## 模型 A 发版流程

1. **在私有源码仓生成正式产物**：使用干净的已提交源码、项目批准的 Xcode 版本和稳定签名身份；正式发布命令必须显式设置 `IFLY_NEW_VERSION_RELEASE=1`。

   ```bash
   export DEVELOPER_DIR=/Applications/Xcode_26.2.app/Contents/Developer
   export IFLY_SDK_CODESIGN_IDENTITY='<已批准的签名身份>'
   VERSION='<新版本>'
   MODEL_A_BASE_URL="https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/${VERSION}"

   IFLY_NEW_VERSION_RELEASE=1 scripts/release-gate.sh
   scripts/build-model-a.sh
   IFLY_NEW_VERSION_RELEASE=1 scripts/package-model-a-release.sh \
     --version "${VERSION}" \
     --base-url "${MODEL_A_BASE_URL}"
   ```

   `release-gate.sh` 负责源码、公开头、iOS 11、行为和实际 XCFramework 门禁；打包脚本负责 7 个模块、合并包、签名、资源闭包和最终分发扫描。

2. **更新私有仓与本公开仓的发布元数据**：

   - 按 `build/modelA/release/checksums.txt` 同步两仓 `Package.swift` 的 7 个 `url + checksum`；
   - 同步 `IFLYADLib.podspec` 的 `s.version` 与合并 zip `s.source(:http)`；
   - 确认 `IFLYADLib.podspec` 的 `Core` 显式链接 `AdSupport`、弱链接 `AppTrackingTransparency`，且最终 Core Mach-O 在 iOS 11～13 不形成 ATT 强依赖；
   - 将 `build/modelA/release/swiftpm-resources/spm/` 同步到本仓 `spm/`，不将该中间目录作为 Release 资产上传；
   - 同步 README、CHANGELOG、迁移说明和示例工程 Podfile/Xcode deployment target；
   - 正式资产和 checksum 均已就绪后，才把本轮准备态措辞更新为正式发布日期和“最新正式版本”，并再次检索仓库确认无冲突状态；
   - 在私有仓执行 `python3 scripts/verify-model-a-release-metadata.py --version "${VERSION}"`，闭环校验产物、checksum 和两个分发清单。

3. **验证并提交本公开仓**：至少执行 `git diff --check`、`ruby -c IFLYADLib.podspec`、`swift package dump-package`、`pod spec lint IFLYADLib.podspec --quick --allow-warnings`、示例工程 `pod install` 与构建；同时用 iOS 11、iOS 13 和 iOS 14+ 宿主验证 Core 链接与启动。Release tag 必须指向这个已包含新清单、最终 checksum、资源和正式版本措辞的提交。

4. **创建 GitHub Release**：tag = `<版本>`（**无 `v` 前缀**），target 指向上一步提交。上传打包脚本产生的 10 个文件：7 个单模块 zip、1 个合并 zip、`checksums.txt` 和 `binary-targets.remote.swift`。

5. **发版后校验**：

   - 确认 tag 与 Release 的 target commit 就是第 3 步提交；
   - 匿名下载 7 个单模块 zip 并与 `Package.swift` checksum 全量比对，同时校验合并 zip 的 7 个 XCFramework、三域资源、`PrivacyInfo.xcprivacy` 和 `LICENSE`；
   - `pod cache clean IFLYADLib --all` 后重跑完整 `pod spec lint`、`pod install` 与示例 workspace 构建；
   - 确认 `.github/workflows/ci.yml` 在发布提交上通过。

6. **（可选）发布到 CocoaPods 官方 trunk**：`pod trunk push IFLYADLib.podspec`。需 owner 的 trunk 会话（owner：`LJMcarryu`、`jmliu6`）。push 成功且 CDN 可查后，再把 README/Podfile 从 tag 固定的 `:podspec` 直连改为 `pod 'IFLYADLib', '<版本>'`。

## 注意事项

- **不要重打已上传的 zip**——内容变了 SPM checksum 就变，会让已下载者校验失败；换版本一律另起新 tag。
- Release 的 tag 必须指向**已含新 `Package.swift` 与 `spm/` 资源**的提交，否则 SPM 消费方会解析到旧清单或旧资源。
- 隐私清单 `PrivacyInfo.xcprivacy` 必须随 `Core` 资源进合并 zip（静态库不能内嵌到 Mach-O）。
- `AdSupport` 必须随 Core 显式链接；`AppTrackingTransparency` 必须保持弱链接，并以实际 Mach-O 依赖和 iOS 11 启动验证为准，不能只检查 podspec 文本。
- 版本号需四处一致：`Package.swift` 的 URL、podspec 的 version 与 source、Release tag、合并 zip 文件名；最低系统在 Package、podspec、示例 Podfile/Xcode 工程和二进制 load command 中保持 iOS 11.0。
- 公开仓为私有源码仓的分发面，**不接受外部代码 PR**；版本只能由维护者经上述流程发布。
