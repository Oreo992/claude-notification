## 通知功能配置

### 微信推送配置
* WeChat Token: `OpyZFXXzPi6CJ3YKs3CnfUPox`

### 主动通知场景
AI 应该在以下场景主动发送通知：
1. **长时间任务完成** - 构建、测试、部署等耗时任务完成时
2. **需要用户确认** - 重要决策或需要用户介入时
3. **重要里程碑** - 代码审查完成、PR 创建成功等
4. **错误警报** - 构建失败、测试未通过等异常情况

### 发送通知方法
使用 Bash 工具调用 wechat.ps1 脚本：

```powershell
# 基础通知
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Users\Administrator\.claude\plugins\cache\claude-notification\windows\1.2.8/skills/notification-config/scripts/wechat.ps1" -Token "OpyZFXXzPi6CJ3YKs3CnfUPox" -Text "任务完成"

# 带详细内容
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Users\Administrator\.claude\plugins\cache\claude-notification\windows\1.2.8/skills/notification-config/scripts/wechat.ps1" -Token "OpyZFXXzPi6CJ3YKs3CnfUPox" -Text "Claude Code" -Desp "代码审查完成"

# 详细通知
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Users\Administrator\.claude\plugins\cache\claude-notification\windows\1.2.8/skills/notification-config/scripts/wechat.ps1" -Token "OpyZFXXzPi6CJ3YKs3CnfUPox" -Text "构建完成" -Desp "项目构建成功，耗时 5 分钟"
```

### 使用原则
* 在用户明确要求通知时发送
* 完成重要任务后主动发送（如代码审查、PR创建、长时间构建等）
* 使用 `-Text` 参数设置标题，`-Desp` 参数设置详细内容
