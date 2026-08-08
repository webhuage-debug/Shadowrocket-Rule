# 配置审计记录

## 0.2.1 — 自动安全检查

状态：开发分支自动检查已实现，CN 的分流、DNS、策略组和远程依赖保持 V0.2.0 不变。

- 自动检查 `[General]`、`[Proxy]`、`[Proxy Group]`、`[Rule]` 与单一 `FINAL`。
- 自动检查策略组引用、选择组成员、重复策略组、重复规则和重复 RULE-SET URL。
- 自动检查 Script、MITM、URL Rewrite、敏感字段、远程可执行扩展名与稳定更新地址。
- 自动测试五个地区的常见节点命名，并确认 `RUS-01`、`RUS Moscow`、`Russia-01` 不进入美国组。
- 自动下载 CN 的 15 个远程规则，拒绝空文件、HTML 页面及不符合允许类型的首条有效规则。
- 检查脚本仅在 GitHub Actions 或维护者本地运行，Shadowrocket 客户端不会下载或执行。

## 0.2.0 — CN 安全优化版

状态：静态审计、自动正则测试及首轮 iPhone 实机验证通过。

### 安全与配置

- CN 不含 `[Script]`、`[MITM]`、`[URL Rewrite]`、远程可执行代码、账号或 Token。
- 删除 Google 中国入口重写及其 HTTPS 解密依赖，不再要求用户安装或信任 CA。
- `block-quic` 保持注释，未全局阻断 QUIC、HTTP/3、Hysteria2、TUIC 或其他 UDP 节点。
- `udp-policy-not-supported-behaviour = REJECT` 仅在已选策略不支持 UDP 时拒绝 UDP，避免静默直连造成出口泄漏；它不会关闭支持 UDP 的节点。
- 关闭 IPv6 是兼容性取舍，用于避免不支持 IPv6 的节点、双栈出口不一致和潜在绕行；实机确认节点能力后可再评估开启。

### DNS 与本地网络

- 主解析器为 AliDNS DoH；Cloudflare、Quad9、Google DoH 作为回退；不回退系统 DNS。
- 代理服务 RULE-SET 使用 `force-remote-dns`，降低受污染本地解析结果影响的概率。
- `private-ip-answer = true`，并将 `.local`、`.lan`、`home.arpa`、反向解析、公共 Wi-Fi 检测、微信本地回调与 Apple Push 加入直连或真实 IP 边界。
- `hijack-dns` 仅接管列出的常见硬编码 53 端口 DNS；无法保证覆盖所有应用自带 DoH/DoQ，也不能把“无明显明文 DNS 回退”表述为绝对零泄漏。
- DNS 参数采用现有 Shadowrocket 常见配置语法；不同 iOS、Shadowrocket 和网络环境的实际行为仍须实机确认。

### 策略与依赖

- 美国缩写改为带边界匹配；自动测试确认 `RUS-01`、`RUS Moscow`、`Russia-01` 均不会进入美国组。
- 地区组与自动选择组加入 `include-all-proxies=true`，用于筛选用户已导入的订阅节点。
- 删除 CN 的香港券商策略、LingJingMaster AI 补充和 Atlassian 规则；CN 当前仅引用 blackmatrix7 的 15 个常用服务 RULE-SET。
- 15 个 URL 于 2026-08-07 静态检查均返回 HTTP 200 与 `text/plain`；下载成功不代表上游未来内容永远正确。
- 配置区段、策略引用、重复组、重复规则、重复 URL 和单一 FINAL 均通过静态检查。

### 实机验证清单

- 导入配置与地区组节点识别；
- AI、YouTube、TikTok、Telegram 默认出口与手动切换；
- 国内直连、微信、Apple Push、NAS/局域网与公共 Wi-Fi 登录；
- DoH 主备切换、DNS 劫持、代理远程 DNS 与失败回退；
- TCP、UDP、Hysteria2、TUIC、QUIC/HTTP3；
- IPv4-only 使用表现及需要 IPv6 的网络；
- 合并 `main` 后验证稳定版 `update-url` 的更新与回滚。

## 0.1.1

状态：静态修复及首轮 iPhone 实机验证完成，可以发布至 GitHub 稳定分支。

发布前需要检查：

- Shadowrocket 配置语法和策略组引用；
- DNS 解析与回退行为；
- 节点名称地区匹配；
- 规则顺序和冲突；
- 所有第三方远程规则的可用性、来源和许可证；
- 是否包含订阅地址、账号、密钥、证书或个人网络信息；
- GitHub Raw 更新地址；
- iPhone 实机导入、连接、更新和回滚。

## 三套配置的额外检查

- `ianzo-cn.conf`：基础平衡版，引用 blackmatrix7 的 Shadowrocket 服务专用规则集。
- `ianzo-full.conf`：引用 `private`、`reject`、`direct`、`proxy` 四个 Loyalsoldier 远程规则集；2026-07-30 链接检测均返回 HTTP 200。
- `ianzo-gfw.conf`：在服务分流后引用 Loyalsoldier `gfw` 远程规则集，随后 `FINAL,DIRECT`；2026-07-30 链接检测返回 HTTP 200。
- 三份配置引用的 16 个 blackmatrix7 Shadowrocket 服务规则链接与 5 个 Loyalsoldier 规则链接已于 2026-07-30 检查，均返回 HTTP 200。
- 三份配置引用的 LingJingMaster `AI.list` 与 `HK_Broker.list` 链接已于 2026-07-30 检查，返回 HTTP 200。
- 三份配置的 TikTok 规则地址已修复为 blackmatrix7 官方 Shadowrocket 路径，并重新检查返回 HTTP 200。
- 三份配置新增 `always-real-ip` 排除项，用于局域网、公共 Wi-Fi 认证、微信本地回调和 Apple 推送；需实机验证 Fake-IP/TUN 行为。
- 全量版四个 Loyalsoldier 规则集约含 309,193 条上游规则，检测到 direct/reject/proxy 之间存在重复项；按配置顺序由 reject、direct、proxy 依次优先处理。
- GFW 版保留“国内网络”和“未命中的境外流量”策略组供手动选择，但最终规则为 `FINAL,DIRECT`，这两个组不参与自动兜底。
- HTTP 200 仅表示规则可下载，发布前仍必须在 Shadowrocket 实机检查导入、规则编译、DNS、流媒体、Apple 推送和回滚行为。
