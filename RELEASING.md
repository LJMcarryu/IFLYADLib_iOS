# 发版手册（维护者）

## 6.4.5 冻结与发布记录

<!-- ifly-release-status: {"schemaVersion":1,"version":"6.4.5","releaseState":"FORMAL","distribution":"github-release","releaseUrl":"https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.4.5"} -->

`6.4.5` 的签名资产、七个 SwiftPM checksum 和 10 项分发资产由同版本真实冻结库存生成；A/B 源码身份见 `release-state.json`。公开时间与消费验证结果以 `release-state.json.publication` 和 [Release 6.4.5](https://github.com/LJMcarryu/IFLYADLib_iOS/releases/tag/6.4.5) 为准。历史 Tag、Release 和资产保持不可变。

本轮仅发布通用模型 A，使用私有仓 `scripts/release-plan-general.json` 和五阶段编排。七模块改为静态 framework；Swift 导入及 Objective-C 头路径变更见[迁移指南](docs/接入指南/Swift模块接入与头路径迁移.md)，共享行为变化见[更新记录](CHANGELOG.md)。

发布消费覆盖 SwiftPM、CocoaPods 示例及手动模块组合；具体结果以绑定当前资产的 Actions 为准。iOS 11 二进制兼容检查不等于真机运行，实际媒体投放需要有效广告位联调。CocoaPods trunk 不在发布范围；Apple Review 未执行时记录 `not-run`。

> 本仓库 `IFLYADLib_iOS` 是**对外分发仓**：只放分发清单、文档、示例，二进制托管在 GitHub Releases。
> SDK 源码与构建脚本在**内部私有源码仓**（不在本仓）。

## 6.4.3 冻结与发布记录

历史记录见[历史发布记录](docs/需求设计/发布验收/历史发布记录.md#643-冻结与发布记录)。

## 6.4.2 冻结与发布记录

历史记录见[历史发布记录](docs/需求设计/发布验收/历史发布记录.md#642-冻结与发布记录)。

## 正式发布唯一入口

新版本正式发布只能从内部私有源码仓根目录的 `scripts/release-orchestrator.py` 发起，并按
`prepare → preflight → publish → verify → closeout` 顺序完成。先用默认只读计划确认候选身份，
只有在版本、Xcode、签名和冻结条件满足时才可为对应阶段显式传入 `--execute`。不得从本公开仓
手工创建或移动 tag、发布 Release，也不得直接派发 candidate 工作流来替代编排器 receipt。

本文后续的 `release-gate.sh`、构建/打包脚本、公开仓校验命令和 GitHub Actions
`workflow_dispatch` 都是底层门禁或故障诊断入口，可用于定位和复验单项问题，但不是正式发布
入口。CI 对同一候选的复验顺序排队且不取消既有 run；候选与正式 Release 使用不同并发组。
重型验证 job 最长运行 55 分钟，结束后由无 Token、只读的 summary job 汇总 Candidate、Release、
checkout commit、资产库存身份和全部 job 结论；summary 对上游失败继续失败关闭。

## 6.4.1 冻结与发布记录

历史记录见[历史发布记录](docs/需求设计/发布验收/历史发布记录.md#641-冻结与发布记录)。

## 6.4.0 冻结与发布记录

历史记录见[历史发布记录](docs/需求设计/发布验收/历史发布记录.md#640-冻结与发布记录)。

## 6.3.5 冻结与发布记录

历史记录见[历史发布记录](docs/需求设计/发布验收/历史发布记录.md#635-冻结与发布记录)。

## 6.3.1 历史发布记录

历史记录见[历史发布记录](docs/需求设计/发布验收/历史发布记录.md#631-历史发布记录)。

## 仓库角色

| 仓库 | 内容 |
| --- | --- |
| 内部私有源码仓 | OC 源码、单元测试、构建脚本（`build-xcframework.sh` / `build-model-a.sh` / `split-resources.sh` / `package-model-a-release.sh`） |
| 本公开仓 `IFLYADLib_iOS` | `Package.swift`（SPM）、`IFLYADLib.podspec`（CocoaPods）、README/文档、示例工程；GitHub Releases 托管 xcframework 二进制 |

## 模型 A 底层门禁与诊断参考

正式态采用两提交模型：二进制从提交 A 构建；提交 B 必须是 A 的后代，且 A→B 只允许修改 `Package.swift`、`README.md`、`CONTEXT.md` 和 `docs/**`。当前 A/B 以目标版本 `release-state.json` 的 `binarySourceCommit` / `releaseMetadataCommit` 为准，不能使用历史归档中的提交。

本节描述编排器各阶段调用和核对的底层事实，供失败定位与维护使用，不得脱离上述唯一入口
独立执行为正式发布。

1. **核对私有源码仓正式产物生成**：编排器必须使用干净的已提交源码、项目批准的 Xcode 版本和稳定签名身份；下列命令仅在私有源码仓用于本地诊断，输出不构成正式发布资产或 receipt；正式模式的 candidate 与构建输入由编排器提供。

   ```bash
   export DEVELOPER_DIR='<本机获准 Xcode.app>/Contents/Developer'
   xcodebuild -version  # 必须与当前计划的 version/build 精确一致
   export IFLY_SDK_CODESIGN_IDENTITY='<本机诊断签名身份>'
   VERSION='<新版本>'
   MODEL_A_BASE_URL="https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/${VERSION}"

   scripts/release-gate.sh
   scripts/build-model-a.sh
   scripts/package-model-a-release.sh \
     --version "${VERSION}" \
     --base-url "${MODEL_A_BASE_URL}"
   ```

   `release-gate.sh` 负责源码、公开头、iOS 11、行为和实际 XCFramework 门禁；打包脚本负责 7 个模块、合并包、签名、资源闭包和分发产物门禁；Apple Review 仅在显式执行 `apple-scan` 时运行。

2. **核对私有仓与本公开仓的发布元数据**：

   - 按 `build/modelA/release/checksums.txt` 同步两仓 `Package.swift` 的 7 个 `url + checksum`；
   - 同步 `IFLYADLib.podspec` 的 `s.version` 与合并 zip `s.source(:http)`；
   - 确认 `IFLYADLib.podspec` 的 `Core` 显式链接 `AdSupport`、弱链接 `AppTrackingTransparency`，且最终 Core Mach-O 在 iOS 11～13 不形成 ATT 强依赖；
   - 将 `build/modelA/release/swiftpm-resources/spm/` 同步到本仓 `spm/`，不将该中间目录作为 Release 资产上传；
   - 同步 README、CHANGELOG、迁移说明和示例工程 Podfile/Xcode deployment target；
   - 按目标版本计划、公开头与 API 变更验证 NativeFeed 固定页和列表页；历史 `6.3.5` 专项验收见[历史发布记录](docs/需求设计/发布验收/历史发布记录.md#635-nativefeed-专项验收)。
   - 正式冻结时由编排器按门禁同步文档 `releaseState=FORMAL` 与真实 checksum，并移除目标候选的未发布措辞；`FORMAL` 不表示发布闭环，机器阶段由 `release-state.json.phase` 记录，正式消费成功后才收口为 `CLOSED`；
   - 在私有仓执行 `python3 scripts/verify-model-a-release-metadata.py --version "${VERSION}"`，闭环校验产物、checksum 和两个分发清单。

3. **核对本公开仓候选**：Release 资产公开前，编排器至少执行 `git diff --check`、`ruby -c IFLYADLib.podspec`、`swift package dump-package`、`pod ipc spec IFLYADLib.podspec`、本地 A/B 文档一致性和冻结 10 资产等价校验；完整 `pod spec lint`、示例工程 `pod install` 与真正 `xcodebuild build` 留到 Release 资产公开后执行。CI 必须对 NativeFeed 新 API 做正向头校验、对 `6.2.1` 历史 API 做反向头校验，并在 Release 事件编译固定页与列表页。Release tag 必须指向已包含最终 checksum、资源和正式版本措辞的提交。

4. **核对编排器发布结果**：tag = `<版本>`（**无 `v` 前缀**），target 指向上一步冻结提交。GitHub Release 必须精确包含打包脚本产生的 10 个文件：7 个单模块 zip、1 个合并 zip、`checksums.txt` 和 `binary-targets.remote.swift`。Release body 必须各出现一次目标版本 `release-state.json` 的 `binarySourceCommit` / `releaseMetadataCommit` 对应的 A/B provenance 声明，并明确“B 仅用于 checksum、扫描汇总和验收事实，不是 SDK 二进制源码提交”。通用库存不含 `delivery-manifest.json`，Release body 不得虚构额外清单声明。

5. **核对发布后校验**：

   - 确认 tag 与 Release 的 target commit 就是第 3 步提交；
   - 匿名下载 7 个单模块 zip 并与 `Package.swift` checksum 全量比对，同时校验合并 zip 的 7 个 XCFramework、三域资源、`PrivacyInfo.xcprivacy` 和 `LICENSE`；
   - `pod cache clean IFLYADLib --all` 后重跑完整 `pod spec lint`、`pod install` 与示例 workspace 构建；
   - 确认 `.github/workflows/ci.yml` 在发布提交上通过。

6. **（可选、正式闭环之外）发布到 CocoaPods 官方 trunk**：只允许在编排器 `closeout` 成功后另行取得 owner 授权，再执行 `pod trunk push IFLYADLib.podspec`（owner：`LJMcarryu`、`jmliu6`）。push 成功且 CDN 可查后，再把 README/Podfile 从 tag 固定的 `:podspec` 直连改为 `pod 'IFLYADLib', '<版本>'`；该动作不替代或回写正式发布 receipt。

## Draft 候选消费控制面

每个候选使用不可覆盖的 `release-candidate/<version>-<candidateId>` 分支。Draft Release 的
`target_commitish` 只能是该分支或分支当前的精确提交；`workflow_dispatch` 必须从该分支触发，
并同时提供正整数 `draft_release_id`、64 位小写 `candidate_id` 和 32 位小写
`dispatch_nonce`。工作流会把 checkout 绑定到触发 SHA，并把 run name 固定为
`draft-candidate:<candidateId>:<releaseId>:<dispatchNonce>`。候选分支在发布完成后暂不删除，
用于失败恢复和证据复验。

启用这套流程前，必须先把只包含 workflow、控制脚本和测试的 bootstrap 提交独立合入远端
`main`；该提交不得同时修改版本、`Package.swift` 或 podspec。否则默认分支尚不能识别新 inputs
和 run-name，编排器无法可靠派发候选验证。之后每版的版本内容门禁仍随候选分支提交更新。

## 注意事项

- Apple Review 为主动可选扫描，策略以目标版本计划为准；未运行记录 `not-run`，不得表述为扫描或 Apple 审核通过，历史版本风险授权不沿用。
- **不要重打已上传的 zip**——内容变了 SPM checksum 就变，会让已下载者校验失败；换版本一律另起新 tag。
- Release 的 tag 必须指向**已含新 `Package.swift` 与 `spm/` 资源**的提交，否则 SPM 消费方会解析到旧清单或旧资源。
- 隐私清单 `PrivacyInfo.xcprivacy` 必须随 `Core` 资源进合并 zip（静态库不能内嵌到 Mach-O）。
- `AdSupport` 必须随 Core 显式链接；`AppTrackingTransparency` 必须保持弱链接，并以实际 Mach-O 依赖和 iOS 11 启动验证为准，不能只检查 podspec 文本。
- 版本号需四处一致：`Package.swift` 的 URL、podspec 的 version 与 source、Release tag、合并 zip 文件名；最低系统在 Package、podspec、示例 Podfile/Xcode 工程和二进制 load command 中保持 iOS 11.0。
- 公开仓为私有源码仓的分发面，**不接受外部代码 PR**；版本只能由维护者经上述流程发布。
