# Claude Code 通知功能配置提示词

将以下内容添加到你项目的 `.claude/CLAUDE.md` 文件中，让 AI 能够在完成任务后主动发送通知。

---

## 📋 复制以下内容到 `.claude/CLAUDE.md`

```markdown
## 通知功能

当你完成重要任务时，应该主动发送通知提醒我。

### 如何发送通知

1. **检查配置**：首先检查 `.claude/claude-notification.local.md` 是否存在
2. **读取 Bark URL**：从配置文件的 YAML frontmatter 中提取 `bark_url`
3. **发送通知**：使用 bark 脚本发送通知

### 通知脚本路径

- **macOS/Linux**: `~/.claude/plugins/cache/claude-notification/unix/*/skills/notification-config/scripts/bark.sh`
- **Windows**: `$env:USERPROFILE\.claude\plugins\cache\claude-notification\windows\*\skills\notification-config\scripts\bark.ps1`

### 使用示例（macOS/Linux）

```bash
# 读取配置并发送通知
if [ -f ".claude/claude-notification.local.md" ]; then
    BARK_URL=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' .claude/claude-notification.local.md | grep '^bark_url:' | sed 's/bark_url: *//' | sed 's/^"\(.*\)"$/\1/' | sed "s/^'\(.*\)'$/\1/")

    if [ -n "$BARK_URL" ]; then
        bash ~/.claude/plugins/cache/claude-notification/unix/*/skills/notification-config/scripts/bark.sh \
            -u "$BARK_URL" \
            -t "Claude Code" \
            -m "任务已完成：[描述任务内容]"
    fi
fi
```

### 使用示例（Windows）

```powershell
# 读取配置并发送通知
$configFile = ".claude/claude-notification.local.md"
if (Test-Path $configFile) {
    $content = Get-Content $configFile -Raw
    if ($content -match '(?s)^---\r?\n(.+?)\r?\n---') {
        $frontmatter = $Matches[1]
        if ($frontmatter -match 'bark_url:\s*[''"]?([^''"}\r\n]+)[''"]?') {
            $barkUrl = $Matches[1].Trim()

            if ($barkUrl) {
                powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.claude\plugins\cache\claude-notification\windows\*\skills\notification-config\scripts\bark.ps1" `
                    -Url $barkUrl `
                    -Title "Claude Code" `
                    -Message "任务已完成：[描述任务内容]"
            }
        }
    }
}
```

### 何时发送通知

在以下场景主动发送通知：

1. ✅ **用户明确要求** - 用户说"完成后通知我"、"用 bark 通知我"
2. ✅ **长时间任务完成** - 构建、测试、部署等耗时超过 30 秒的操作
3. ✅ **重要里程碑** - 代码审查完成、PR 创建成功、发布完成
4. ✅ **需要用户关注** - 构建失败、测试不通过、发现重要问题

### 注意事项

- 只在重要时刻发送通知，不要过度打扰用户
- 如果用户没有配置 Bark（bark_url 为空），静默跳过
- 通知消息要简洁明了，说明完成了什么任务
- 使用通配符 `*` 匹配插件版本号
```

---

## 🚀 快速开始

1. 在你的项目根目录创建 `.claude/CLAUDE.md` 文件
2. 复制上面的内容到文件中
3. 配置 Bark URL（如果还没配置）：
   ```bash
   # 创建配置文件
   mkdir -p .claude
   cat > .claude/claude-notification.local.md << 'EOF'
   ---
   bark_url: "https://api.day.app/your-key"
   ---
   EOF
   ```
4. 测试：对 AI 说"帮我创建一个文件，完成后通知我"

## 📝 示例对话

**用户**：帮我运行测试，完成后用 bark 通知我

**AI 应该做**：
1. 运行测试：`npm test`
2. 读取 bark_url 配置
3. 发送通知：`bark.sh -u "$BARK_URL" -t "测试完成" -m "所有测试通过"`

---

## 💡 提示

- 将此文件保存为 `NOTIFICATION_SETUP.md` 供参考
- 每个项目都可以有自己的 `.claude/CLAUDE.md` 配置
- 配置文件 `.claude/claude-notification.local.md` 应该加入 `.gitignore`
