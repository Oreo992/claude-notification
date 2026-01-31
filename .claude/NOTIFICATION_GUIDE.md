# 通知功能使用指南

当你完成重要任务时，可以主动发送通知提醒用户。

## 如何发送通知

### 方法 1：使用 Bark 推送（推荐）

如果用户配置了 Bark，使用以下命令：

```bash
# macOS/Linux
bash ~/.claude/plugins/cache/claude-notification/unix/*/skills/notification-config/scripts/bark.sh -u "用户的Bark URL" -t "标题" -m "消息内容"

# Windows
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.claude\plugins\cache\claude-notification\windows\*\skills\notification-config\scripts\bark.ps1" -Url "用户的Bark URL" -Title "标题" -Message "消息内容"
```

### 方法 2：读取配置文件

更好的方式是从项目配置文件读取 Bark URL：

```bash
# 1. 检查配置文件是否存在
if [ -f ".claude/claude-notification.local.md" ]; then
    # 2. 提取 bark_url
    BARK_URL=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' .claude/claude-notification.local.md | grep '^bark_url:' | sed 's/bark_url: *//' | sed 's/^"\(.*\)"$/\1/')

    # 3. 如果配置了 Bark，发送通知
    if [ -n "$BARK_URL" ]; then
        bash ~/.claude/plugins/cache/claude-notification/unix/*/skills/notification-config/scripts/bark.sh -u "$BARK_URL" -t "Claude Code" -m "任务已完成"
    fi
fi
```

## 何时发送通知

在以下场景主动发送通知：

1. **长时间任务完成** - 构建、测试、部署等耗时操作
2. **用户明确要求** - 用户说"完成后通知我"
3. **重要里程碑** - 代码审查完成、PR 创建成功
4. **错误需要关注** - 构建失败、测试不通过

## 示例

```bash
# 用户说："帮我运行测试，完成后通知我"
# 你应该：
npm test && bash ~/.claude/plugins/cache/claude-notification/unix/*/skills/notification-config/scripts/bark.sh -u "$BARK_URL" -t "测试完成" -m "所有测试通过"

# 用户说："创建文件后用 bark 通知我"
# 你应该：
# 1. 创建文件
# 2. 读取配置中的 bark_url
# 3. 发送通知
```

## 注意事项

- 通知脚本路径使用通配符 `*` 匹配版本号
- 优先从 `.claude/claude-notification.local.md` 读取配置
- 如果用户没有配置 Bark，静默跳过通知
- 不要为每个小操作都发送通知，只在重要时刻使用
