# Render 部署指南

本指南将帮助您将 Douyin_TikTok_Download_API 项目部署到 Render 平台。

## 前置准备

1. **GitHub 账号**: 确保您的项目已上传到 GitHub
2. **Render 账号**: 访问 [render.com](https://render.com) 注册免费账号
3. **项目配置**: 确保项目包含优化后的 `Dockerfile` 和 `render.yaml`

## 部署步骤

### 1. 连接 GitHub 仓库

1. 登录 Render 控制台
2. 点击 "New +" 按钮
3. 选择 "Web Service"
4. 连接您的 GitHub 账号
5. 选择 `Douyin_TikTok_Download_API` 仓库

### 2. 配置服务设置

**基本设置:**
- **Name**: `douyin-tiktok-api` (或您喜欢的名称)
- **Region**: `Oregon (US West)` (推荐)
- **Branch**: `main`
- **Runtime**: `Docker`

**构建设置:**
- **Dockerfile Path**: `./Dockerfile`
- **Docker Context**: `.`
- **Build Command**: 留空 (Docker 会自动处理)
- **Start Command**: `python3 start.py`

### 3. 环境变量配置

在 "Environment Variables" 部分添加以下变量:

```
PYTHONUNBUFFERED=1
PORT=10000
HOST_IP=0.0.0.0
ENVIRONMENT=production
```

**可选环境变量:**
```
# 如果需要自定义配置
API_VERSION=V4.1.2
DOWNLOAD_SWITCH=true
PYWEBIO_ENABLE=true
```

### 4. 高级设置

**健康检查:**
- **Health Check Path**: `/docs`

**自动部署:**
- 启用 "Auto-Deploy" 以便 GitHub 推送时自动部署

### 5. 部署

1. 点击 "Create Web Service"
2. Render 将开始构建您的应用
3. 构建过程大约需要 3-5 分钟
4. 部署成功后，您将获得一个 `.onrender.com` 域名

## 部署后验证

### 1. 检查服务状态

访问您的应用 URL，应该能看到 API 文档页面:
```
https://your-app-name.onrender.com/docs
```

### 2. 测试 API 端点

测试基本的 API 功能:
```bash
curl https://your-app-name.onrender.com/api/hybrid/video_data
```

### 3. 查看日志

在 Render 控制台的 "Logs" 标签页查看应用日志，确保没有错误。

## 常见问题解决

### 1. 构建失败

**问题**: Docker 构建超时或失败
**解决方案**:
- 检查 `requirements.txt` 中的依赖是否正确
- 确保 Dockerfile 语法正确
- 查看构建日志中的具体错误信息

### 2. 应用启动失败

**问题**: 服务显示 "Deploy failed"
**解决方案**:
- 检查 `start.py` 中的端口配置
- 确保环境变量 `PORT` 已正确设置
- 查看应用日志中的错误信息

### 3. 健康检查失败

**问题**: 服务显示不健康状态
**解决方案**:
- 确保 `/docs` 端点可访问
- 检查防火墙设置
- 验证应用是否正确绑定到 `0.0.0.0`

### 4. 免费版限制

**Render 免费版限制:**
- 服务在 15 分钟无活动后会休眠
- 每月 750 小时免费运行时间
- 重启时间约 30 秒
- 512MB RAM 限制

**优化建议:**
- 使用外部监控服务定期访问保持活跃
- 考虑升级到付费计划以获得更好性能

## 自定义域名 (可选)

如果您有自己的域名:

1. 在 Render 控制台点击 "Settings"
2. 找到 "Custom Domains" 部分
3. 添加您的域名
4. 按照说明配置 DNS 记录

## 监控和维护

### 1. 监控服务状态

- 使用 Render 控制台监控 CPU 和内存使用情况
- 设置 Webhook 通知服务状态变化

### 2. 日志管理

- 定期查看应用日志
- 使用外部日志服务 (如 Papertrail) 进行长期存储

### 3. 更新部署

- 推送代码到 GitHub 将自动触发重新部署
- 可以在 Render 控制台手动触发部署

## 成本估算

**免费版:**
- 0 美元/月
- 750 小时免费运行时间
- 适合个人项目和测试

**付费版 (Starter):**
- 7 美元/月
- 24/7 运行
- 更好的性能和支持

## 技术支持

如果遇到问题:

1. 查看 [Render 官方文档](https://render.com/docs)
2. 检查项目的 GitHub Issues
3. 联系 Render 技术支持

---

**注意**: 本指南基于 Render 平台的当前功能，平台功能可能会有更新变化。建议部署前查看 Render 官方最新文档。