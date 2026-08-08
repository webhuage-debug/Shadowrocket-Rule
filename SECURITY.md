# Security Policy

## 安全设计原则

CN 安全优化版遵循以下默认边界：

- 无 `[Script]`，不执行 JavaScript、Python、Shell 或其他客户端代码。
- 默认无 `[MITM]`，不要求安装或信任 CA。
- 无 `[URL Rewrite]`，不修改 HTTP/HTTPS 请求或响应。
- 不解密 HTTPS。
- 无遥测、统计或设备信息上传。
- 不收集账号、Cookie、Token、订阅或节点信息。
- 配置仅管理 DNS、路由规则、策略组、节点选择和流量出口。

## 第三方依赖

| 项目 | URL | CN 用途 | 风险边界 |
| --- | --- | --- | --- |
| blackmatrix7/ios_rule_script | <https://github.com/blackmatrix7/ios_rule_script> | OpenAI、Anthropic、Claude、GitHub、GitLab、YouTube、Netflix、Disney、Spotify、Google、TikTok、Facebook、Telegram、Twitter、Apple 的 Shadowrocket 规则 | 仅远程读取规则文本；内容、可用性与许可证由上游维护，更新可能改变匹配结果 |

CN 版不远程加载 JavaScript、Shell、Python、二进制程序或任何可执行资源。LingJingMaster 的 AI 补充与香港券商规则已从 CN 移除；FULL/GFW 仍是待后续审计的上游原版，依赖详情见 `docs/SOURCES.md`。

仓库中的 `scripts/validate-cn.sh` 只用于 GitHub Actions 和维护者本地检查，不属于 Shadowrocket 配置依赖，不会通过 `update-url` 或 `RULE-SET` 下载到客户端执行。

## 供应链边界

远程 RULE-SET 可在本仓库不变的情况下由上游更新。本项目只能审计引用地址、规则格式和某一时点的内容，无法保证上游未来永不误分流。敏感业务应固定出口并定期复核规则命中情况。

## 重大安全变更公告

未来如计划新增以下任何能力，必须在发布前于 CHANGELOG、README 和 Release Notes 中显著公告，并重新进行安全审计：

- Script 或任何客户端脚本；
- MITM、CA 或 HTTPS 解密；
- URL Rewrite、请求修改或响应修改；
- 远程可执行资源；
- 遥测、统计或设备信息上传；
- 账号、Cookie、Token、订阅或节点数据收集。

## 漏洞报告

请通过 GitHub Issue 报告可复现的配置错误、误分流、远程依赖异常或安全问题。报告中请勿提交真实节点、订阅链接、账号、Token、Cookie 或其他敏感信息。
