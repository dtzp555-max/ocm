# OCM FAQ

## Q: Telegram 群里经常显示 typing，但不回消息？

Most common cause is **BotFather Group Privacy** being ON.

Fix:
- BotFather → Your bot → Bot Settings → **Group Privacy** → **Turn off**

Also check:
- `openclaw status` (gateway healthy?)
- provider auth/rate limits (OCM → Auth page, and gateway logs)

## Q: 如何获取 Telegram Group ID（Peer ID / -100...）？

Typical workflow:

```bash
openclaw gateway logs --follow
```

Send a message in the target group; the gateway logs usually contain the peer id.

## Q: 模型下拉列表为什么没有我想要的模型？

OCM sources model options from the real CLI output:

```bash
openclaw models list
```

So if it doesn't show up in OCM, make sure it's registered/available in your OpenClaw environment.

## Q: Dashboard 里 Gateway HTTP Ping 显示 Unreachable？

Common reasons:
- Gateway not running
- Gateway binds to a different interface/port than OCM expects
- Local firewall/proxy interference

Try:
- `openclaw status`
- `openclaw gateway restart`

## Q: OCM 会把我的 token/个人信息上传出去吗？

OCM is designed as a **local** dashboard.

That said, your local OpenClaw config contains sensitive information. Follow the safety guidance:
- keep agent Telegram groups private
- don't share raw screenshots without redaction

See: `docs/SECURITY.md`.


## Q: 为什么 OCM 暂时不推荐 WhatsApp 的 sub-agent 工作流？

WhatsApp 在 bot / group 自动化、权限边界和稳定路由上限制更多。

OCM 的 sub-agent 模式依赖清晰的会话边界、独立路由和可控权限，因此目前更推荐 Telegram / Discord 这类更容易做隔离的渠道。

如果未来支持 WhatsApp，更可能先从通知或轻量交互开始，而不是多 sub-agent 群聊拓扑。
