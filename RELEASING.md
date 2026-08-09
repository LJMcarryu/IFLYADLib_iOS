# 发版手册（维护者）

> 本仓库 `IFLYADLib_iOS` 是**对外分发仓**：只放分发清单、文档、示例，二进制托管在 GitHub Releases。
> SDK 源码与构建脚本在**内部私有源码仓**（不在本仓）。

## 当前发布状态

当前最新公开正式版是 `6.2.1`（2026-08-07）。`6.2.2` 的正式签名资产已从提交 A 构建、扫描并冻结，Podspec、Package URL、Demo 与 7 个 SwiftPM checksum 已同步；不可变 tag、GitHub Release、无 Token 匿名下载和最终消费验证尚未完成，对应 URL 当前不可用。

- `releaseState`：`FORMAL`
- `binarySourceCommit`（SDK 二进制源码提交）：`a8ec925d3731d7d11734647aa02ca7d91d674965`
- `releaseMetadataCommit`（仅回填 checksum、扫描汇总和发布验收事实，不是 SDK 二进制源码提交）：`eff78263c2d3f65b029f4114de1a9ed00f3827f3`

`releaseState=FORMAL` 只表示正式签名资产与发布元数据已经冻结，不表示本仓已公开发布。合并包 `IFLYADLib-modelA-6.2.2.zip` 的冻结 SHA-256 为 `f24cf6ea1d4e4319fbcef0fdb79a29aee5906f9bc35d81453052a6341379a673`。

正式态使用两提交模型：全部二进制从提交 A 构建；提交 B 必须是 A 的后代，且 A→B 只能修改 `Package.swift`、`README.md`、`CONTEXT.md` 和 `docs/**`。正式 CI 通过 `IFLY_PRIVATE_SOURCE_TOKEN` 调用私有源码仓 compare API 验证，令牌不用于公开 Release 资产下载。

不可变 tag、GitHub Release、匿名下载复验与 CI 仍必须按下方流程逐项留证；未取得对应证据前，不得在验收记录中写成已经通过。

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
   - NativeFeed API 变更须同步固定页和列表页，并复验数据层只持 Ad、Cell 不持 Session/Binding、进屏 Ad 级 attach、离屏按容器 detach、回屏恢复、最后引用释放自动终止和可选 `destroy`；
   - 正式资产和 checksum 均已就绪后，将 `releaseState` 切换为 `FORMAL`，但在 tag/Release 与匿名验证完成前继续明确标注“尚未公开发布”；发布闭环后才写入正式发布日期和“最新公开正式版本”；
   - 在私有仓执行 `python3 scripts/verify-model-a-release-metadata.py --version "${VERSION}"`，闭环校验产物、checksum 和两个分发清单。

3. **验证并提交本公开仓**：Release 资产公开前至少执行 `git diff --check`、`ruby -c IFLYADLib.podspec`、`swift package dump-package`、`pod ipc spec IFLYADLib.podspec`、本地 A/B 文档一致性和冻结 10 资产等价校验；完整 `pod spec lint`、示例工程 `pod install` 与真正 `xcodebuild build` 留到 Release 资产公开后执行。CI 必须对 NativeFeed 新 API 做正向头校验、对 `6.2.1` 历史 API 做反向头校验，并在 Release 事件编译固定页与列表页。Release tag 必须指向已包含最终 checksum、资源和正式版本措辞的提交。

4. **创建 GitHub Release**：tag = `<版本>`（**无 `v` 前缀**），target 指向上一步提交。上传打包脚本产生的 10 个文件：7 个单模块 zip、1 个合并 zip、`checksums.txt` 和 `binary-targets.remote.swift`。Release body 必须各出现一次本节记录的 A/B provenance 声明，并明确“B 仅用于 checksum、扫描汇总和验收事实，不是 SDK 二进制源码提交”。通用库存不含 `delivery-manifest.json`，Release body 不得虚构额外清单声明。

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
