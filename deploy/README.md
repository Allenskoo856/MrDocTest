# 🚀 MrDoc 部署文件

本目录包含 MrDoc 项目的所有部署相关文件和脚本。

## 📁 文件说明

### Docker 配置文件
- `Dockerfile` - 主要的Docker构建文件（x86_64/AMD64架构）
- `Dockerfile-loongarch64` - 龙芯架构的Docker构建文件
- `docker-compose.yml` - 基础Docker Compose配置（仅MrDoc应用）
- `docker-compose-with-mysql.yml` - 完整Docker Compose配置（包含MySQL、Redis等）

### 启动脚本
- `docker_mrdoc.sh` - Docker容器启动脚本
- `docker-update.sh` - Docker镜像更新脚本
- `setup_env.sh` - 环境变量设置脚本（用于MySQL配置）

### 配置文件
- `config-docker.ini.example` - Docker部署配置文件示例

### 管理脚本
- `scripts/backup.sh` - 数据备份脚本
- `scripts/restore.sh` - 数据恢复脚本

## 🚀 部署方式

### 1. 使用预构建镜像（推荐）

如果项目已配置 GitHub Actions，可以直接使用预构建的 Docker 镜像：

```bash
# 基础部署（使用预构建镜像）
docker run -d -p 10086:10086 --name mrdoc YOUR_DOCKERHUB_USERNAME/mrdoc:latest

# 使用 Docker Compose——编辑 docker-compose.yml 修改镜像名称
services:
  mrdoc:
    image: YOUR_DOCKERHUB_USERNAME/mrdoc:latest
    # ... 其他配置
```

### 2. 简单部署（仅应用）

```bash
# 启动基础服务
docker-compose up -d

# 查看日志
docker-compose logs -f
```

### 2. 完整部署（应用+数据库+缓存）

```bash
# 启动完整服务栈
docker-compose -f docker-compose-with-mysql.yml up -d

# 查看所有服务状态
docker-compose -f docker-compose-with-mysql.yml ps
```

### 3. 本地开发环境

```bash
# 设置MySQL环境变量
source setup_env.sh

# 返回项目根目录启动开发服务器
cd ..
python manage.py runserver
```

## ⚙️ 配置说明

### 环境变量配置（推荐）

通过Docker Compose的environment字段配置：

```yaml
environment:
  # 数据库配置
  DATABASE_ENGINE: mysql
  DATABASE_NAME: mrdoc
  DATABASE_USER: mrdoc_user
  DATABASE_PASSWORD: mrdoc_password
  DATABASE_HOST: mysql
  
  # LDAP配置
  LDAP_ENABLE: "true"
  LDAP_SERVER_URI: "ldap://ldap-server:389"
```

### 配置文件方式

1. 复制配置文件模板：
```bash
cp config-docker.ini.example ../config/config.ini
```

2. 编辑配置文件：
```bash
vim ../config/config.ini
```

## 🛠️ 维护操作

### 数据备份

```bash
# 备份所有数据（数据库+媒体文件+配置）
./scripts/backup.sh
```

### 数据恢复

```bash
# 列出可用备份
./scripts/restore.sh

# 恢复指定备份
./scripts/restore.sh 20231209_143022
```

### 服务更新

```bash
# 停止服务
docker-compose down

# 更新镜像
docker-compose pull

# 重新启动
docker-compose up -d
```

## 📋 目录结构

```
deploy/
├── Dockerfile                          # Docker构建文件
├── Dockerfile-loongarch64               # 龙芯架构Docker文件
├── docker-compose.yml                  # 基础Compose配置
├── docker-compose-with-mysql.yml       # 完整Compose配置
├── docker_mrdoc.sh                     # 容器启动脚本
├── docker-update.sh                    # 更新脚本
├── setup_env.sh                        # 环境设置脚本
├── config-docker.ini.example           # 配置文件示例
└── scripts/                            # 管理脚本目录
    ├── backup.sh                       # 备份脚本
    └── restore.sh                      # 恢复脚本
```

## 🔧 故障排除

### 常见问题

1. **容器无法启动**
   ```bash
   # 检查日志
   docker-compose logs
   
   # 检查端口占用
   netstat -tlnp | grep 10086
   ```

2. **数据库连接失败**
   ```bash
   # 检查MySQL服务
   docker-compose ps mysql
   
   # 检查数据库日志
   docker-compose logs mysql
   ```

3. **配置不生效**
   ```bash
   # 检查配置文件挂载
   docker-compose exec mrdoc ls -la /app/MrDoc/config/
   
   # 检查环境变量
   docker-compose exec mrdoc env | grep -E "(DATABASE|LDAP)"
   ```

### 性能优化

1. **增加内存限制**
   ```yaml
   deploy:
     resources:
       limits:
         memory: 1G
   ```

2. **配置Redis缓存**
   - 使用 `docker-compose-with-mysql.yml` 配置
   - 修改配置文件中的缓存设置

## 📞 获取帮助

- 查看详细文档：`../docs/DOCKER_DEPLOYMENT_GUIDE.md`
- 查看LDAP配置：`../docs/LDAP_DOCKER_GUIDE.md`
- 项目主页：返回上级目录查看 `README.md`