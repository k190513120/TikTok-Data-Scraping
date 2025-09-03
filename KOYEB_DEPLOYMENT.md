# Koyeb平台部署指南

本指南将帮助您将Douyin_TikTok_Download_API项目部署到Koyeb平台。

## 🌟 Koyeb平台优势

- **全球CDN**: 14个全球数据中心，低延迟访问
- **免费额度**: 每月免费100GB流量和512MB RAM
- **自动扩缩容**: 根据流量自动调整实例数量
- **Git集成**: 支持GitHub/GitLab自动部署
- **零配置SSL**: 自动HTTPS证书

## 📋 部署前准备

### 1. 账号注册
1. 访问 [koyeb.com](https://www.koyeb.com)
2. 使用GitHub账号注册（推荐）或邮箱注册
3. 验证邮箱地址

### 2. 项目准备
确保您的项目包含以下文件：
- ✅ `Dockerfile` - Docker构建文件
- ✅ `koyeb.yaml` - Koyeb配置文件
- ✅ `requirements.txt` - Python依赖
- ✅ `start.py` - 启动脚本

## 🚀 部署步骤

### 方法一：通过Koyeb控制台部署（推荐）

#### 步骤1：创建新应用
1. 登录Koyeb控制台
2. 点击 **"Create App"**
3. 选择 **"Deploy from GitHub"**

#### 步骤2：连接GitHub仓库
1. 授权Koyeb访问您的GitHub账号
2. 选择包含项目的仓库
3. 选择要部署的分支（通常是main或master）

#### 步骤3：配置服务
1. **服务名称**: `tiktok-api`
2. **构建方式**: 选择 "Dockerfile"
3. **端口配置**: 80
4. **实例类型**: Nano（免费层）
5. **区域选择**: 根据目标用户选择最近的区域
   - 亚洲用户：Singapore (sin)
   - 欧洲用户：Frankfurt (fra)
   - 美洲用户：Washington (was)

#### 步骤4：环境变量配置
在Environment Variables部分添加：

**基础配置**:
```
PORT=80
HOST=0.0.0.0
PYTHONUNBUFFERED=1
API_HOST=0.0.0.0
```

**敏感配置**（使用Secrets）:
1. 在Koyeb控制台创建Secret：
   - 名称：`TIKTOK_COOKIES`
   - 值：您的TikTok Cookie字符串
2. 在环境变量中引用：
   ```
   TIKTOK_COOKIES=@secret:TIKTOK_COOKIES
   ```

#### 步骤5：健康检查配置
- **Health Check Path**: `/docs`
- **Port**: 80
- **Initial Delay**: 30秒
- **Timeout**: 5秒
- **Interval**: 10秒

#### 步骤6：部署
1. 检查所有配置
2. 点击 **"Deploy"**
3. 等待构建和部署完成（通常需要2-5分钟）

### 方法二：使用Koyeb CLI部署

#### 步骤1：安装Koyeb CLI
```bash
# macOS (推荐使用Homebrew)
brew install koyeb/tap/koyeb

# Linux
curl -fsSL https://cli.koyeb.com/install.sh | sh

# Windows (使用Scoop)
scoop bucket add koyeb https://github.com/koyeb/scoop-koyeb
scoop install koyeb

# 验证安装
koyeb version
```

#### 步骤2：CLI认证和登录
```bash
# 登录Koyeb（会打开浏览器进行OAuth认证）
koyeb auth login

# 验证登录状态
koyeb auth whoami

# 查看组织信息
koyeb organization list
```

#### 步骤3：创建应用和服务
```bash
# 创建应用
koyeb app create tiktok-api

# 创建服务（基本配置）
koyeb service create tiktok-api-service \
  --app tiktok-api \
  --git github.com/yourusername/Douyin_TikTok_Download_API \
  --git-branch main \
  --git-build-command "docker build -t app ." \
  --git-run-command "python3 start.py" \
  --ports 80:http \
  --routes /:80 \
  --instance-type nano \
  --regions fra \
  --min-scale 1 \
  --max-scale 1
```

#### 步骤4：配置环境变量
```bash
# 设置基础环境变量
koyeb service update tiktok-api-service \
  --env PORT=80 \
  --env HOST=0.0.0.0 \
  --env PYTHONUNBUFFERED=1 \
  --env API_HOST=0.0.0.0

# 创建Secret存储敏感信息
koyeb secret create tiktok-cookies --value "your_tiktok_cookies_here"

# 引用Secret作为环境变量
koyeb service update tiktok-api-service \
  --env TIKTOK_COOKIES=@secret:tiktok-cookies
```

#### 步骤5：配置健康检查
```bash
# 更新服务健康检查配置
koyeb service update tiktok-api-service \
  --health-check-http-path "/docs" \
  --health-check-http-port 80 \
  --health-check-grace-period 30s \
  --health-check-interval 10s \
  --health-check-restart-limit 3 \
  --health-check-timeout 5s
```

#### 步骤6：部署状态检查
```bash
# 查看应用列表
koyeb app list

# 查看服务状态
koyeb service list --app tiktok-api

# 查看服务详细信息
koyeb service describe tiktok-api-service

# 实时查看部署日志
koyeb service logs tiktok-api-service --follow

# 查看最近的日志
koyeb service logs tiktok-api-service --tail 100
```

#### 步骤7：使用自动化部署脚本

为了简化部署流程，我们提供了一个自动化部署脚本 `deploy-koyeb.sh`：

```bash
# 给脚本添加执行权限
chmod +x deploy-koyeb.sh

# 运行自动化部署
./deploy-koyeb.sh
```

**脚本功能特性**：
- ✅ 自动检查CLI安装和登录状态
- ✅ 交互式输入TikTok Cookies
- ✅ 自动创建应用、服务和Secret
- ✅ 配置环境变量和健康检查
- ✅ 实时监控部署状态
- ✅ 显示部署结果和管理命令

**脚本配置选项**（可在脚本顶部修改）：
```bash
APP_NAME="tiktok-api"              # 应用名称
SERVICE_NAME="tiktok-api-service"  # 服务名称
GIT_REPO="github.com/yourusername/Douyin_TikTok_Download_API"  # Git仓库
REGION="fra"                       # 部署区域 (sin/was/fra)
INSTANCE_TYPE="nano"               # 实例类型 (nano/micro/small)
```

### CLI管理和监控命令

#### 服务管理
```bash
# 查看所有应用
koyeb app list

# 查看应用详情
koyeb app describe tiktok-api

# 删除应用（谨慎操作）
koyeb app delete tiktok-api

# 查看所有服务
koyeb service list

# 查看服务详情
koyeb service describe tiktok-api-service

# 重新部署服务
koyeb service redeploy tiktok-api-service

# 暂停服务
koyeb service pause tiktok-api-service

# 恢复服务
koyeb service resume tiktok-api-service

# 删除服务
koyeb service delete tiktok-api-service
```

#### 环境变量管理
```bash
# 查看环境变量
koyeb service describe tiktok-api-service --output json | jq '.env'

# 更新环境变量
koyeb service update tiktok-api-service --env NEW_VAR=value

# 删除环境变量
koyeb service update tiktok-api-service --env NEW_VAR-

# 批量更新环境变量
koyeb service update tiktok-api-service \
  --env PORT=80 \
  --env HOST=0.0.0.0 \
  --env DEBUG=false
```

#### Secret管理
```bash
# 查看所有Secrets
koyeb secret list

# 查看Secret详情
koyeb secret describe tiktok-cookies

# 更新Secret值
koyeb secret update tiktok-cookies --value "new_cookie_value"

# 删除Secret
koyeb secret delete tiktok-cookies
```

#### 日志监控
```bash
# 实时查看日志
koyeb service logs tiktok-api-service --follow

# 查看最近100行日志
koyeb service logs tiktok-api-service --tail 100

# 查看指定时间范围的日志
koyeb service logs tiktok-api-service --since 1h
koyeb service logs tiktok-api-service --since "2024-01-01 10:00:00"

# 过滤错误日志
koyeb service logs tiktok-api-service | grep -i error

# 导出日志到文件
koyeb service logs tiktok-api-service --tail 1000 > app.log
```

#### 性能监控
```bash
# 查看服务指标
koyeb service describe tiktok-api-service --output json | jq '.metrics'

# 查看实例状态
koyeb service describe tiktok-api-service --output json | jq '.instances'

# 查看部署历史
koyeb service describe tiktok-api-service --output json | jq '.deployments'
```

#### 扩缩容管理
```bash
# 手动扩容
koyeb service update tiktok-api-service --min-scale 2 --max-scale 5

# 设置自动扩缩容
koyeb service update tiktok-api-service \
  --autoscaling-average-cpu 70 \
  --autoscaling-average-mem 80 \
  --autoscaling-requests-per-second 100

# 查看扩缩容配置
koyeb service describe tiktok-api-service --output json | jq '.scaling'
```

#### 域名和路由管理
```bash
# 查看服务域名
koyeb service describe tiktok-api-service --output json | jq '.public_domain'

# 添加自定义域名
koyeb service update tiktok-api-service --routes "yourdomain.com/:80"

# 查看路由配置
koyeb service describe tiktok-api-service --output json | jq '.routes'
```

## 🔧 配置说明

### 环境变量详解

| 变量名 | 说明 | 示例值 |
|--------|------|--------|
| `PORT` | 服务端口 | `80` |
| `HOST` | 绑定地址 | `0.0.0.0` |
| `PYTHONUNBUFFERED` | Python输出缓冲 | `1` |
| `TIKTOK_COOKIES` | TikTok访问Cookie | `sessionid=xxx;...` |
| `API_HOST` | API服务地址 | `0.0.0.0` |

### 实例类型选择

| 类型 | CPU | 内存 | 价格 | 适用场景 |
|------|-----|------|------|----------|
| Nano | 0.1 vCPU | 512MB | 免费 | 开发测试 |
| Micro | 0.25 vCPU | 1GB | $5.5/月 | 轻量生产 |
| Small | 0.5 vCPU | 2GB | $11/月 | 中等负载 |

### 区域选择建议

- **亚太地区用户**: Singapore (sin)
- **欧洲用户**: Frankfurt (fra)
- **北美用户**: Washington (was)
- **全球用户**: 可选择多区域部署

## 📊 部署后验证

### 1. 检查服务状态
```bash
# 使用CLI检查
koyeb service list
koyeb service logs tiktok-api
```

### 2. 访问API文档
部署成功后，访问：
```
https://your-app-name-your-org.koyeb.app/docs
```

### 3. 测试API接口
```bash
# 测试健康检查
curl https://your-app-name-your-org.koyeb.app/docs

# 测试TikTok API
curl -X POST "https://your-app-name-your-org.koyeb.app/api/v1/tiktok" \
  -H "Content-Type: application/json" \
  -d '{"url": "https://www.tiktok.com/@username", "count": 5}'
```

## 🔍 故障排除

### 常见问题

#### 1. 部署失败
**症状**: 构建过程中出错
**解决方案**:
- 检查Dockerfile语法
- 确认requirements.txt中的依赖版本
- 查看构建日志定位具体错误

#### 2. 服务无法启动
**症状**: 健康检查失败
**解决方案**:
- 检查PORT环境变量设置
- 确认start.py中的端口绑定
- 查看应用日志

#### 3. Cookie失效
**症状**: TikTok API返回空数据
**解决方案**:
- 更新TIKTOK_COOKIES环境变量
- 检查Cookie格式是否正确
- 确认Cookie未过期

#### 4. 地理位置限制
**症状**: 某些地区无法访问TikTok
**解决方案**:
- 更换部署区域
- 使用代理服务
- 配置VPN连接

### 日志查看
```bash
# 实时查看日志
koyeb service logs tiktok-api --follow

# 查看历史日志
koyeb service logs tiktok-api --since 1h
```

## 🔄 更新部署

### 自动部署
Koyeb支持Git集成，当您推送代码到GitHub时会自动触发部署。

### 手动部署
```bash
# 触发重新部署
koyeb service redeploy tiktok-api
```

## 💰 成本优化

### 免费层限制
- **流量**: 100GB/月
- **构建时间**: 100分钟/月
- **实例**: 1个Nano实例
- **存储**: 2.5GB

### 优化建议
1. **使用多阶段构建**减少镜像大小
2. **配置合适的健康检查间隔**
3. **监控流量使用情况**
4. **合理设置自动扩缩容策略**

## 🔐 安全最佳实践

1. **使用Secrets管理敏感信息**
2. **定期更新Cookie和API密钥**
3. **启用访问日志监控**
4. **配置适当的CORS策略**
5. **使用HTTPS访问**

## 📞 技术支持

- **Koyeb文档**: https://www.koyeb.com/docs
- **社区论坛**: https://community.koyeb.com
- **GitHub Issues**: 项目仓库的Issues页面

---

🎉 **恭喜！** 您已成功将TikTok API部署到Koyeb平台。现在可以享受全球化的高性能API服务了！