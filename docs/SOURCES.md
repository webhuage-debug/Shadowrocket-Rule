# 第三方规则来源

本项目所有配置均以远程引用方式使用第三方规则集；规则内容不会复制或提交到本仓库。

## blackmatrix7/ios_rule_script

- 项目：<https://github.com/blackmatrix7/ios_rule_script>
- 使用格式：仅引用 `rule/Shadowrocket/` 下各服务的专用 `.list` 文件。
- 使用范围：CN V0.2.x 使用 OpenAI、Anthropic、Claude、GitHub、GitLab、YouTube、Netflix、Disney、Spotify、Google、TikTok、Facebook、Telegram、Twitter、Apple；FULL/GFW 原版还包含 Atlassian。
- 使用方式：三份配置均通过 `RULE-SET` 远程引用；不复制或再发布该项目的规则内容。CN V0.2.x 将 YouTube 拆分为独立策略组。
- 责任边界：上游项目有自己的免责声明和转载限制；本项目仅登记远程依赖，规则内容、许可证和维护状态以其上游仓库声明为准。

## Loyalsoldier/surge-rules

- 项目：<https://github.com/Loyalsoldier/surge-rules>
- 使用分支：`release`
- 使用格式：`ruleset/*.txt`，以 Shadowrocket 的 `RULE-SET` 远程引用。
- 全量规则版：`private.txt`、`reject.txt`、`direct.txt`、`proxy.txt`。
- GFW 模式：`gfw.txt`。
- 更新策略：上游项目通过 GitHub Actions 定期构建；本项目不复制其规则内容。
- 责任边界：规则的准确性、可用性、更新和许可证以其上游仓库声明为准。

## LingJingMaster/Shadowrocket-Rules

- 项目：<https://github.com/LingJingMaster/Shadowrocket-Rules>
- 使用文件：未优化的 FULL/GFW 原版仍使用 `AI.list` 与 `HK_Broker.list`；CN V0.2.x 不再引用该项目。
- 使用范围：`AI.list` 补充 xAI、Grok 等 AI 服务；`HK_Broker.list` 提供香港券商相关分流。两者仅存在于待后续优化的 FULL/GFW 原版。
- 使用方式：通过 `RULE-SET` 远程引用，不复制或再发布这些文件内容。CN V0.2.x 因规则重叠、普通用户价值和供应链精简原则，已移除这两个依赖。
- 责任边界：规则内容、许可证和维护状态以其上游仓库声明为准。

## 使用原则

1. 每次新增外部规则前，记录项目、文件、用途、格式和启用日期。
2. 只引用明确适配 Surge/Shadowrocket 语法的规则文件。
3. 第三方规则失效或误分流时，优先禁用对应引用，不把上游文件复制入仓库修补。
4. 全量和 GFW 模式属于可选配置；用户应在 Shadowrocket 中先测试网络、DNS 与流媒体可用性。
