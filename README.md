# Shadowrocket-Rule 华哥安全优化版

面向普通用户长期使用的 Shadowrocket 安全精简分流配置。当前重点维护 **CN 平衡版**：国内服务直连，常用境外服务可独立选择出口，并默认关闭会解密 HTTPS 的功能。

本项目 Fork 自 [ianzo0/Shadowrocket-Rule](https://github.com/ianzo0/Shadowrocket-Rule)，保留原作者贡献记录及 MIT License。V0.2.0 的安全优化由 `webhuage-debug` 维护，不代表原始项目全部由当前维护者原创。

## 安全边界

- 不提供节点、机场或订阅服务。
- 不收集用户信息、账号、Cookie、Token 或节点信息。
- 不包含 JavaScript、Python 或客户端远程执行脚本。
- CN 默认版本不启用 MITM，不要求安装或信任 CA。
- CN 默认版本不启用 URL Rewrite，不解密 HTTPS。
- 远程依赖仅用于域名、IP 与 GeoIP 类分流规则；规则内容可随上游更新。

详细安全设计与第三方依赖边界见 [SECURITY.md](SECURITY.md)，规则来源见 [docs/SOURCES.md](docs/SOURCES.md)。

## 版本选择

| 配置 | 状态 | 适合用户 |
| --- | --- | --- |
| `ianzo-cn.conf` | **V0.2.0 华哥安全优化版，待 iPhone 实机验证** | 大多数普通用户 |
| `ianzo-full.conf` | 上游原版，待后续安全优化 | 需要更多通用规则的用户 |
| `ianzo-gfw.conf` | 上游原版，待后续安全优化 | 仅希望按 GFWList 分流的用户 |

> FULL 和 GFW 尚未完成本轮安全优化，仍保留原版 MITM、URL Rewrite 和上游更新地址，不应视为“华哥安全版”。

## 稳定版下载地址

以下为合并到 `main` 后的目标地址。开发分支验证期间，CN 配置内的自动更新地址保持注释状态。

### CN 平衡版（本轮优化）

```text
https://raw.githubusercontent.com/webhuage-debug/Shadowrocket-Rule/main/ianzo-cn.conf
```

### FULL 全量版（原版 / 待后续安全优化）

```text
https://raw.githubusercontent.com/webhuage-debug/Shadowrocket-Rule/main/ianzo-full.conf
```

### GFW 版（原版 / 待后续安全优化）

```text
https://raw.githubusercontent.com/webhuage-debug/Shadowrocket-Rule/main/ianzo-gfw.conf
```

## CN 版默认策略

| 服务 | 默认出口 | 可否手动更改 |
| --- | --- | --- |
| ChatGPT、Claude 等 AI 服务 | 美国节点组 | 可以 |
| YouTube | 香港节点组 | 可以 |
| TikTok | 日本节点组 | 可以 |
| Telegram | 新加坡节点组 | 可以 |
| Google、GitHub、流媒体、Meta、X | 主节点选择 | 可以 |
| Apple、Apple Push、国内服务 | DIRECT | 可以；Apple Push 固定直连 |
| 未命中流量 | 主节点选择 | 可以 |

地区组依赖节点名称识别。如果订阅没有相应地区节点，或命名方式不在识别范围内，请在 Shadowrocket 中为业务策略手动选择可用节点。地区组是便捷默认值，不等于强制锁定国家或固定公网 IP。

## DNS 与网络说明

- 主 DNS 使用 AliDNS DoH，备用使用 Cloudflare、Quad9 与 Google DoH。
- 代理服务规则使用 `force-remote-dns`，降低受污染解析结果影响的概率。
- 局域网、NAS、`.local`、`.lan`、`home.arpa`、公共 Wi-Fi 登录、微信本地回调与 Apple Push 已加入直连或真实 IP 例外。
- 默认关闭 IPv6，以降低节点不支持 IPv6、双栈出口不一致或 IPv6 绕行带来的兼容性风险；需要 IPv6 的用户应在实机验证节点能力后自行开启。
- `block-quic` 保持关闭，不全局破坏 Hysteria2、TUIC、QUIC、HTTP/3 或其他 UDP 流量。
- DNS 服务商仍可看到其处理的域名查询；“加密 DNS”不等于完全匿名或绝对无泄漏。

## 使用前提示

1. 当前 V0.2.0 已完成静态检查，但仍需 iPhone 实机导入、连接、DNS、局域网、公共 Wi-Fi、微信、Apple Push、UDP 与更新回滚测试。
2. 涉及账号风控的服务，请手动固定一条稳定节点，不要依赖自动测速频繁切换出口。
3. 第三方 RULE-SET 会独立更新；下载成功不代表内容永远正确，出现误分流时应先停用对应规则并反馈。

## License 与上游来源

本仓库继续采用 [MIT License](LICENSE)，原版权声明 `Copyright (c) 2026 ianzo` 保持不变。上游项目：<https://github.com/ianzo0/Shadowrocket-Rule>。