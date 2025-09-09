#!/bin/bash

# MrDoc 数据恢复脚本
# 使用方法: ./restore.sh [backup_date]
# 例如: ./restore.sh 20231209_143022

set -e

# 配置
BACKUP_DIR="./backup"
MYSQL_CONTAINER="mrdoc-mysql"
MYSQL_DATABASE="mrdoc"
MYSQL_USER="root"
MYSQL_PASSWORD="root_password_123"

# 检查参数
if [ $# -eq 0 ]; then
    echo "使用方法: $0 [backup_date]"
    echo "可用的备份文件:"
    ls -la $BACKUP_DIR/ | grep -E "\.(sql|tar\.gz)$" | awk '{print $9}' | sort | uniq
    exit 1
fi

BACKUP_DATE=$1

# 检查备份文件是否存在
DB_BACKUP="$BACKUP_DIR/mrdoc_db_$BACKUP_DATE.sql"
MEDIA_BACKUP="$BACKUP_DIR/media_$BACKUP_DATE.tar.gz"
CONFIG_BACKUP="$BACKUP_DIR/config_$BACKUP_DATE.tar.gz"

echo "开始恢复 MrDoc 数据 (备份日期: $BACKUP_DATE)..."

# 确认操作
read -p "警告: 此操作将覆盖现有数据，确定继续吗？(y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "操作已取消"
    exit 1
fi

# 1. 恢复数据库
if [ -f "$DB_BACKUP" ]; then
    echo "正在恢复数据库..."
    if docker ps | grep -q $MYSQL_CONTAINER; then
        # 停止应用服务避免数据冲突
        echo "停止MrDoc应用服务..."
        docker-compose stop mrdoc || true
        
        # 恢复数据库
        docker exec -i $MYSQL_CONTAINER mysql \
            -u $MYSQL_USER \
            -p$MYSQL_PASSWORD \
            $MYSQL_DATABASE < $DB_BACKUP
        echo "数据库恢复完成"
    else
        echo "错误: MySQL容器未运行"
        exit 1
    fi
else
    echo "警告: 数据库备份文件不存在: $DB_BACKUP"
fi

# 2. 恢复媒体文件
if [ -f "$MEDIA_BACKUP" ]; then
    echo "正在恢复媒体文件..."
    # 备份当前媒体文件
    if [ -d "./media" ]; then
        mv ./media ./media.backup.$(date +%Y%m%d_%H%M%S)
    fi
    # 恢复媒体文件
    tar -xzf $MEDIA_BACKUP
    echo "媒体文件恢复完成"
else
    echo "警告: 媒体文件备份不存在: $MEDIA_BACKUP"
fi

# 3. 恢复配置文件
if [ -f "$CONFIG_BACKUP" ]; then
    echo "正在恢复配置文件..."
    # 备份当前配置文件
    if [ -d "./config" ]; then
        mv ./config ./config.backup.$(date +%Y%m%d_%H%M%S)
    fi
    # 恢复配置文件
    tar -xzf $CONFIG_BACKUP
    echo "配置文件恢复完成"
else
    echo "警告: 配置文件备份不存在: $CONFIG_BACKUP"
fi

# 4. 重启服务
echo "正在重启服务..."
docker-compose up -d

# 5. 等待服务启动
echo "等待服务启动..."
sleep 10

# 6. 检查服务状态
echo "检查服务状态..."
docker-compose ps

echo ""
echo "恢复完成！"
echo "请检查应用是否正常运行: http://localhost:10086"

# 7. 显示恢复的文件信息
echo ""
echo "已恢复的备份文件:"
[ -f "$DB_BACKUP" ] && echo "- 数据库: $(ls -lh $DB_BACKUP | awk '{print $5, $9}')"
[ -f "$MEDIA_BACKUP" ] && echo "- 媒体文件: $(ls -lh $MEDIA_BACKUP | awk '{print $5, $9}')"
[ -f "$CONFIG_BACKUP" ] && echo "- 配置文件: $(ls -lh $CONFIG_BACKUP | awk '{print $5, $9}')"