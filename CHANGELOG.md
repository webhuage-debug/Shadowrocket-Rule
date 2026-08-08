# Changelog

## 0.2.1 — 2026-08-08

- 保持 V0.2.0 的 CN 分流、DNS 与安全边界不变。
- 新增可本地运行的 CN 自动验证脚本，检查配置区段、FINAL、策略引用、重复规则和重复远程地址。
- 将香港、美国、日本、新加坡、台湾节点识别样本及 `RUS` 防误判样本纳入自动测试。
- 自动阻止 CN 引入 Script、MITM、URL Rewrite、敏感字段或远程可执行资源。
- 校验稳定版 `update-url`、15 个 GitHub Raw `.list` 来源及远程规则文本格式。
- GitHub Actions 增加手动触发和每周定时检查，持续监测第三方规则可用性。

## 0.2.0 — 2026-08-08

- 移除 CN 默认 MITM、HTTPS 解密及依赖 MITM 的 Google URL Rewrite。
- 修复美国节点裸 `US` 匹配导致 `RUS-01` 等名称误判的问题。
- 为地区节点增加带边界的缩写识别，并兼容 HKG、JPN、SGP、TWN、TPE 及常见城市名称。
- 为地区与自动测速组启用 `include-all-proxies=true`，确保能筛选用户已导入的订阅节点。
- 精简 CN 普通用户策略组，删除小众“香港券商”策略与对应远程规则。
- 将 YouTube 从综合流媒体中拆分，完善 AI、代码、Google、YouTube、流媒体、TikTok、Meta、Telegram、X 与 Apple 的独立策略。
- 审计 CN 的 DNS、IPv6、局域网、公共 Wi-Fi、微信、Apple Push、UDP 与 QUIC 配置；补充 `.lan`、`home.arpa` 和 Apple Push 真实 IP 边界。
- 审计 CN 远程 RULE-SET，保留 blackmatrix7 常用服务规则，移除重复度较高的 AI 补充规则和低频 Atlassian 依赖。
- 将 CN 更新地址迁移至 `webhuage-debug/Shadowrocket-Rule` 并在稳定版启用。
- 重写 README 安全说明并新增 `SECURITY.md`。
- 完成首轮 iPhone 实机导入与核心分流验证。

## 0.1.3 — 2026-07-30

- 配置文件统一移除 `-rule`：更名为 `ianzo-cn.conf`、`ianzo-full.conf` 和 `ianzo-gfw.conf`，并同步更新配置内更新地址、文档和自动化校验。
- 将三套配置的导入与更新地址前置到 README，每条地址均可单独复制。

## 0.1.2 — 2026-07-30

- 将“节点选择”、AI、Google 与 Meta 的默认出口统一为通用自动测速；美国、日本、新加坡、香港等地区组改为可选的手动出口。
- 写入正式 GitHub 更新地址，导入 Shadowrocket 后可直接检查并更新配置。

## 0.1.1 — 2026-07-30

- 修复三套配置中 TikTok 远程规则地址被策略组图标误改的问题。
- 更新 GitHub Actions 校验目标，改为检查 `ianzo-cn.conf`、`ianzo-full.conf` 和 `ianzo-gfw.conf`。
- 为局域网、公共 Wi-Fi 认证、微信本地回调和 Apple 推送加入 `always-real-ip` 排除项。
- 收紧 Google 中国入口重写的主机名边界。
- 补充全量版规则规模、Fake-IP 边界、地区节点命名要求和 GFW 版未使用策略组说明。

## 0.1.0 — 2026-07-29

- 创建独立项目骨架。
- 添加具备逐行中文说明的 `ianzo-cn.conf` 最小可测试配置。
- 加入局域网、AI 与开发、国际媒体、即时通讯、Apple 服务和中国大陆 IP 的基础分流。
- 增加加密 DNS 回退、常见硬编码 DNS 劫持、Google、TikTok 与 Meta 的最小可审查规则。
- 重写地区节点分组，支持香港、美国、日本、台湾、新加坡和其他节点的自动测速与服务级切换。
- 增加独立的 Apple Push Notification service 分流策略与 `push.apple.com` 规则。
- 拆分 Telegram 与 X（原 Twitter）策略组，使两类服务可独立选择出口。
- 增加 Apple、Android 与 Windows 的公共 Wi-Fi 认证/连通性探测直连规则，以及微信显式直连规则。
- 增加 g.cn、google.cn 到 www.google.com 的 URL Rewrite，并将 MITM 范围限制为这些域名。
- 新增全量规则版与 GFW 模式；新增第三方远程规则来源登记文档。
- 将服务分流拆为 AI 与代码托管两组，并改为引用第三方 Shadowrocket 专用规则集。
- 将“国际流媒体”更名为“流媒体 Netflix/Disney+”，并加入默认直连、可手动切换香港节点的券商服务规则。
- 添加项目说明、许可证和审计文档占位。
