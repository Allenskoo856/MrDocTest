# 🚀 GitHub Actions Docker 自动构建配置指南

本项目已配置 GitHub Actions 自动构建和推送 Docker 镜像到 DockerHub。

## 📋 配置要求

### 1. GitHub Secrets 配置

在 GitHub 仓库设置中，需要添加以下 Secrets：

#### 必需的 Secrets：
- `DOCKERHUB_USERNAME`: 您的 DockerHub 用户名
- `DOCKERHUB_TOKEN`: DockerHub 访问令牌（不是密码）

#### 如何获取 DockerHub Token：
1. 登录 [DockerHub](https://hub.docker.com/)
2. 点击右上角头像 → Account Settings
3. 选择 Security → New Access Token
4. 创建一个具有 Read, Write, Delete 权限的 Token
5. 复制生成的 Token（只显示一次）

#### 如何添加 GitHub Secrets：
1. 进入 GitHub 仓库页面
2. 点击 Settings → Secrets and variables → Actions
3. 点击 New repository secret
4. 分别添加上述两个 secrets

## 🔄 工作流说明

### 基础工作流 (`docker-build-push.yml`)
- **触发条件**: 推送到 master/main 分支
- **功能**: 构建并推送 Docker 镜像
- **平台支持**: linux/amd64, linux/arm64
- **标签策略**: 
  - `latest` (默认分支)
  - 分支名
  - Git SHA 短码

### 高级工作流 (`docker-advanced.yml`)
- **触发条件**: 推送到 master/main 分支、创建 Tag、Pull Request
- **功能**:
  - 代码质量检查 (flake8)
  - Docker 镜像构建和推送
  - 安全漏洞扫描 (Trivy)
- **标签策略**:
  - 语义版本 (如果是 tag)
  - 分支名 + Git SHA
  - `latest` (默认分支)

## 🏷️ 镜像标签说明

构建完成后，镜像将推送到：
```
docker.io/[YOUR_USERNAME]/mrdoc:latest
docker.io/[YOUR_USERNAME]/mrdoc:master
docker.io/[YOUR_USERNAME]/mrdoc:master-abc1234
```

## 🚀 使用构建的镜像

### 拉取最新镜像
```bash
docker pull [YOUR_USERNAME]/mrdoc:latest
```

### 运行容器
```bash
# 基础运行
docker run -d -p 10086:10086 --name mrdoc [YOUR_USERNAME]/mrdoc:latest

# 使用 Docker Compose (修改 deploy/docker-compose.yml)
services:
  mrdoc:
    image: [YOUR_USERNAME]/mrdoc:latest
    # ... 其他配置
```

## ⚙️ 自定义配置

### 修改镜像名称
编辑 `.github/workflows/*.yml` 文件中的 `IMAGE_NAME` 环境变量：
```yaml
env:
  IMAGE_NAME: your-custom-name  # 默认是 mrdoc
```

### 修改触发分支
```yaml
on:
  push:
    branches: [ master, main, develop ]  # 添加更多分支
```

### 添加更多平台支持
```yaml
platforms: linux/amd64,linux/arm64,linux/arm/v7
```

## 🔍 监控构建状态

1. 进入 GitHub 仓库页面
2. 点击 Actions 标签页
3. 查看工作流运行状态和日志

## ⚠️ 注意事项

1. **首次运行**: 确保已正确配置 DockerHub Secrets
2. **字体文件**: 工作流会自动下载中文字体文件
3. **构建时间**: 首次构建可能需要 10-15 分钟
4. **多平台构建**: arm64 平台构建时间较长
5. **私有仓库**: 确保 DockerHub 仓库权限设置正确

## 🎯 最佳实践

1. **使用 Tag 发布**: 创建 Git Tag 触发版本化构建
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. **定期更新依赖**: 定期更新 GitHub Actions 版本

3. **监控安全扫描**: 关注 Security 标签页的漏洞报告

4. **缓存优化**: 工作流已配置构建缓存，加速后续构建

## 📞 故障排除

### 常见问题：
1. **认证失败**: 检查 DockerHub Secrets 配置
2. **构建超时**: 考虑减少平台支持或优化 Dockerfile
3. **推送失败**: 检查 DockerHub 仓库权限和配额

### 调试方法：
1. 查看 Actions 运行日志
2. 本地测试 Docker 构建
3. 验证 DockerHub Token 权限