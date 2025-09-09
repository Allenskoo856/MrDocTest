# MrDoc Docker 部署指南

## 📋 目录结构

Docker部署时的推荐目录结构：

```
MrDocTest/
├── docker-compose.yml              # 基础Docker Compose配置
├── docker-compose-with-mysql.yml   # 包含MySQL的完整配置
├── config/
│   ├── config.ini                  # 主配置文件
│   ├── config-docker.ini.example   # 配置文件示例
│   └── uwsgi.ini                   # uWSGI配置
├── media/                          # 媒体文件目录（图片、附件等）
├── static/                         # 静态文件目录
├── log/                           # 日志目录
├── backup/                        # 备份目录
├── mysql/                         # MySQL配置目录
│   ├── conf.d/                    # MySQL配置文件
│   └── init/                      # 初始化SQL脚本
└── redis/                         # Redis配置目录
    └── redis.conf                 # Redis配置文件
```

## 🚀 快速开始

### 1. 基础部署（仅MrDoc）

```bash
# 1. 创建必要的目录
mkdir -p {config,media,static,log,backup}

# 2. 复制配置文件
cp config/config-docker.ini.example config/config.ini

# 3. 编辑配置文件
vim config/config.ini

# 4. 启动服务
docker-compose up -d

# 5. 查看日志
docker-compose logs -f
```

### 2. 完整部署（MrDoc + MySQL + Redis）

```bash
# 1. 创建完整目录结构
mkdir -p {config,media,static,log,backup,mysql/conf.d,mysql/init,redis}

# 2. 配置文件设置
cp config/config-docker.ini.example config/config.ini
# 编辑config.ini，设置数据库host为mysql，缓存backend为redis

# 3. 启动完整服务
docker-compose -f docker-compose-with-mysql.yml up -d

# 4. 等待服务启动
docker-compose -f docker-compose-with-mysql.yml ps

# 5. 查看服务状态
docker-compose -f docker-compose-with-mysql.yml logs
```

## ⚙️ 配置文件挂载

### 支持的挂载点

| 容器路径 | 宿主机路径 | 说明 |
|---------|-----------|------|
| `/app/MrDoc/config` | `./config` | 配置文件目录 |
| `/app/MrDoc/media` | `./media` | 媒体文件（图片、附件） |
| `/app/MrDoc/static` | `./static` | 静态文件 |
| `/app/MrDoc/log` | `./log` | 日志文件 |
| `/app/MrDoc/backup` | `./backup` | 备份文件 |

### 配置优先级

1. **环境变量** (最高优先级)
2. **挂载的config.ini文件**
3. **容器内默认配置** (最低优先级)

### 环境变量配置

可以通过环境变量覆盖配置文件设置：

```yaml
environment:
  # 数据库配置
  DATABASE_ENGINE: mysql
  DATABASE_NAME: mrdoc
  DATABASE_USER: mrdoc_user
  DATABASE_PASSWORD: mrdoc_password
  DATABASE_HOST: mysql
  DATABASE_PORT: 3306
  
  # LDAP配置
  LDAP_ENABLE: "true"
  LDAP_SERVER_URI: "ldap://ldap-server:389"
  LDAP_BIND_DN: "cn=admin,dc=example,dc=com"
  LDAP_BIND_PASSWORD: "admin_password"
  
  # 缓存配置
  CACHE_BACKEND: redis
  CACHE_LOCATION: "redis:6379"
```

## 🔧 高级配置

### MySQL配置优化

创建 `mysql/conf.d/mysql.cnf`：

```ini
[mysqld]
# 字符集设置
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci
init_connect = 'SET NAMES utf8mb4'

# 性能优化
max_connections = 1000
innodb_buffer_pool_size = 256M
innodb_log_file_size = 64M
innodb_flush_log_at_trx_commit = 2
sync_binlog = 0

# 时区设置
default-time-zone = '+08:00'
```

### Redis配置优化

创建 `redis/redis.conf`：

```conf
# 基础配置
bind 0.0.0.0
port 6379
protected-mode no

# 内存配置
maxmemory 256mb
maxmemory-policy allkeys-lru

# 持久化配置
save 900 1
save 300 10
save 60 10000

# 日志配置
loglevel notice
logfile ""

# 客户端配置
timeout 0
tcp-keepalive 300
```

### Nginx反向代理（可选）

创建 `nginx/nginx.conf`：

```nginx
upstream mrdoc_backend {
    server mrdoc:10086;
}

server {
    listen 80;
    server_name your-domain.com;
    
    client_max_body_size 50M;
    
    location /static/ {
        alias /var/www/static/;
        expires 30d;
    }
    
    location /media/ {
        alias /var/www/media/;
        expires 7d;
    }
    
    location / {
        proxy_pass http://mrdoc_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## 🛠️ 维护操作

### 数据备份

```bash
# 备份数据库
docker-compose exec mysql mysqldump -u root -p mrdoc > backup/mrdoc_$(date +%Y%m%d_%H%M%S).sql

# 备份媒体文件
tar -czf backup/media_$(date +%Y%m%d_%H%M%S).tar.gz media/

# 备份配置文件
tar -czf backup/config_$(date +%Y%m%d_%H%M%S).tar.gz config/
```

### 数据恢复

```bash
# 恢复数据库
docker-compose exec -T mysql mysql -u root -p mrdoc < backup/mrdoc_backup.sql

# 恢复媒体文件
tar -xzf backup/media_backup.tar.gz
```

### 日志管理

```bash
# 查看应用日志
docker-compose logs -f mrdoc

# 查看数据库日志
docker-compose logs -f mysql

# 清理日志
docker-compose logs --no-color | head -1000 > logs_backup.txt
docker system prune -f
```

### 更新应用

```bash
# 1. 备份数据
./backup.sh

# 2. 停止服务
docker-compose down

# 3. 更新镜像
docker-compose pull

# 4. 启动服务
docker-compose up -d

# 5. 检查服务状态
docker-compose ps
```

## 🚨 故障排除

### 常见问题

1. **配置文件不生效**
   - 检查挂载路径是否正确
   - 检查文件权限
   - 检查环境变量设置

2. **数据库连接失败**
   - 检查MySQL服务是否启动
   - 检查数据库配置是否正确
   - 检查网络连接

3. **静态文件无法访问**
   - 检查static目录挂载
   - 检查文件权限
   - 重新收集静态文件

4. **媒体文件丢失**
   - 检查media目录挂载
   - 检查文件权限

### 调试命令

```bash
# 进入容器调试
docker-compose exec mrdoc bash

# 查看容器资源使用
docker stats

# 查看网络连接
docker-compose exec mrdoc netstat -tlnp

# 测试数据库连接
docker-compose exec mrdoc python manage.py dbshell
```

## 📝 最佳实践

1. **生产环境建议**
   - 使用专用的MySQL和Redis服务器
   - 配置SSL证书和HTTPS
   - 设置定期备份任务
   - 监控服务状态和性能

2. **安全建议**
   - 修改默认密码
   - 限制网络访问
   - 定期更新镜像
   - 配置防火墙规则

3. **性能优化**
   - 配置Redis缓存
   - 使用Nginx反向代理
   - 优化数据库配置
   - 定期清理日志文件