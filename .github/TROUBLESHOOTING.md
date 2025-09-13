# 🚨 GitHub Actions Docker 构建故障排除指南

## 常见错误及解决方案

### 1. "Username and password required" 错误

**错误信息：**
```
Error: Username and password required
```

**原因：**
- GitHub 仓库中缺少必要的 Secrets 配置
- DockerHub 认证信息未正确设置

**解决步骤：**

#### 步骤 1: 获取 DockerHub Access Token
1. 登录 [DockerHub](https://hub.docker.com/)
2. 点击右上角头像 → **Account Settings**
3. 选择左侧 **Security** 标签
4. 点击 **New Access Token**
5. 输入 Token 名称（如：`github-actions`）
6. 选择权限：**Read, Write, Delete**
7. 点击 **Generate** 生成 Token
8. **⚠️ 重要：立即复制 Token（只显示一次）**

#### 步骤 2: 在 GitHub 中配置 Secrets
1. 进入您的 GitHub 仓库页面
2. 点击 **Settings** 标签
3. 在左侧菜单选择 **Secrets and variables** → **Actions**
4. 点击 **New repository secret**
5. 添加以下两个 Secrets：

**DOCKERHUB_USERNAME**
- Name: `DOCKERHUB_USERNAME`
- Secret: 您的 DockerHub 用户名

**DOCKERHUB_TOKEN**
- Name: `DOCKERHUB_TOKEN`
- Secret: 刚才生成的 Access Token

### 2. 其他常见错误

#### 错误：镜像推送失败
**可能原因：**
- DockerHub 仓库不存在
- Token 权限不足
- 网络连接问题

**解决方法：**
1. 确保 DockerHub 仓库存在或允许自动创建
2. 检查 Token 权限包含 Write 权限
3. 重新生成 Token

#### 错误：构建超时
**可能原因：**
- 多平台构建时间过长
- 网络下载速度慢

**解决方法：**
1. 减少构建平台（只保留 linux/amd64）
2. 使用构建缓存加速
3. 优化 Dockerfile

### 3. 验证配置

#### 检查 Secrets 是否正确配置
1. 进入 GitHub 仓库 → Settings → Secrets and variables → Actions
2. 确认存在以下 Secrets：
   - ✅ DOCKERHUB_USERNAME
   - ✅ DOCKERHUB_TOKEN

#### 测试 DockerHub 连接
在本地测试 DockerHub 登录：
```bash
# 使用相同的凭据测试登录
docker login docker.io
# 输入用户名和 Access Token
```

### 4. 工作流文件检查

确保工作流文件中的配置正确：

```yaml
- name: 登录 DockerHub
  uses: docker/login-action@v3
  with:
    registry: docker.io  # 明确指定注册表
    username: ${{ secrets.DOCKERHUB_USERNAME }}
    password: ${{ secrets.DOCKERHUB_TOKEN }}  # 使用 Token，不是密码
```

### 5. 调试技巧

#### 查看详细日志
1. 进入 GitHub 仓库 → Actions
2. 点击失败的工作流运行
3. 展开失败的步骤查看详细错误信息

#### 本地调试
```bash
# 1. 检查 Dockerfile 语法
docker build --no-cache -t test-build .

# 2. 测试多平台构建
docker buildx create --use
docker buildx build --platform linux/amd64,linux/arm64 .

# 3. 测试字体文件下载
curl -L -o SourceHanSerifCN-Medium.otf "https://github.com/adobe-fonts/source-han-serif/raw/release/OTF/SimplifiedChinese/SourceHanSerifCN-Medium.otf"
```

### 6. 推荐的工作流配置

使用改进版的工作流文件 `docker-build-improved.yml`，它包含：
- ✅ 详细的错误检查
- ✅ 清晰的错误提示
- ✅ 自动验证 Secrets 配置
- ✅ 更好的日志输出

### 7. 最佳实践

1. **定期更新 Token**：DockerHub Token 建议定期更换
2. **使用专用 Token**：为 CI/CD 创建专门的 Access Token
3. **监控构建状态**：设置构建失败通知
4. **缓存策略**：合理使用构建缓存减少构建时间

### 8. 紧急情况处理

如果需要临时禁用自动构建：
1. 进入 GitHub 仓库 → Actions
2. 选择工作流 → Disable workflow
3. 或者编辑工作流文件，注释掉触发条件

### 📞 获取帮助

如果问题仍然存在：
1. 检查 GitHub Actions 日志
2. 验证 DockerHub 账户状态
3. 参考 [Docker Login Action 文档](https://github.com/docker/login-action)
4. 查看项目的 `.github/DOCKER_ACTIONS_GUIDE.md` 文件