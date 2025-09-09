# MrDoc - 私有云文档部署方案

MrDoc 是一个基于 Python 的开源在线文档系统，适用于个人和中小型团队的知识管理、云笔记、云文档私有化部署需求。

## 📁 项目结构

```
MrDocTest/
├── 📁 docs/                    # 📚 文档目录
│   ├── DOCKER_DEPLOYMENT_GUIDE.md    # Docker部署指南
│   ├── LDAP_DOCKER_GUIDE.md          # LDAP Docker配置指南
│   ├── GEMINI.md                      # 项目说明文档
│   └── README-zh.md                   # 中文说明文档
├── 📁 deploy/                  # 🚀 部署目录
│   ├── docker-compose.yml            # 基础Docker Compose配置
│   ├── docker-compose-with-mysql.yml # 包含MySQL的完整配置
│   ├── Dockerfile                     # Docker构建文件
│   ├── Dockerfile-loongarch64         # 龙芯架构Docker文件
│   ├── docker_mrdoc.sh               # Docker启动脚本
│   ├── docker-update.sh              # Docker更新脚本
│   ├── setup_env.sh                  # 环境设置脚本
│   ├── config-docker.ini.example     # Docker配置文件示例
│   └── 📁 scripts/                   # 部署脚本
│       ├── backup.sh                 # 数据备份脚本
│       └── restore.sh                # 数据恢复脚本
├── 📁 MrDoc/                   # 🌐 Django项目配置
│   ├── settings.py
│   ├── urls.py
│   └── wsgi.py
├── 📁 app_admin/              # 👥 管理应用
├── 📁 app_api/                # 🔌 API应用
├── 📁 app_doc/                # 📄 文档应用
├── 📁 config/                 # ⚙️ 配置文件
├── 📁 template/               # 🎨 模板文件
├── 📁 static/                 # 📦 静态资源
├── manage.py                   # Django管理脚本
└── requirements.txt            # Python依赖
```

## 🚀 快速开始

### 本地开发

```bash
# 1. 安装依赖
pip install -r requirements.txt

# 2. 设置环境变量（如果使用MySQL）
source deploy/setup_env.sh

# 3. 数据库迁移
python manage.py makemigrations
python manage.py migrate

# 4. 创建超级用户
python manage.py createsuperuser

# 5. 启动开发服务器
python manage.py runserver
```

### Docker部署

```bash
# 基础部署
cd deploy
docker-compose up -d

# 完整部署（包含MySQL和Redis）
cd deploy  
docker-compose -f docker-compose-with-mysql.yml up -d
```

## 📚 文档

- [Docker部署指南](docs/DOCKER_DEPLOYMENT_GUIDE.md) - 完整的Docker部署说明
- [LDAP配置指南](docs/LDAP_DOCKER_GUIDE.md) - LDAP认证配置
- [中文文档](docs/README-zh.md) - 详细的中文说明

## 🛠️ 维护操作

```bash
# 数据备份
cd deploy
./scripts/backup.sh

# 数据恢复  
cd deploy
./scripts/restore.sh [backup_date]

# 更新应用
cd deploy
./docker-update.sh
```

## 🌟 主要功能

- **多种编辑模式**: 支持 Markdown 和富文本编辑
- **文档协作**: 支持多人协作编辑和权限控制
- **文档导出**: 支持 PDF、EPUB 等格式导出
- **全文搜索**: 基于 Whoosh 的全文检索
- **LDAP认证**: 支持企业级LDAP用户认证
- **多数据库**: 支持 MySQL、PostgreSQL、SQLite
- **容器化部署**: 完整的Docker部署方案

## 📄 许可证

本项目采用开源许可证，详情请查看相关文档。

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进项目。

---

📖 **获取更多信息**: 查看 `docs/` 目录中的详细文档
🚀 **开始部署**: 查看 `deploy/` 目录中的部署文件