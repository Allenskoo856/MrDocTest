#!/bin/bash

# MrDoc 数据备份脚本
# 使用方法: ./backup.sh

set -e

# 配置
BACKUP_DIR="./backup"
DATE=$(date +%Y%m%d_%H%M%S)
MYSQL_CONTAINER="mrdoc-mysql"
MYSQL_DATABASE="mrdoc"
MYSQL_USER="root"
MYSQL_PASSWORD="root_password_123"

# 创建备份目录
mkdir -p $BACKUP_DIR

echo "开始备份 MrDoc 数据..."

# 1. 备份数据库
echo "正在备份数据库..."
if docker ps | grep -q $MYSQL_CONTAINER; then
    docker exec $MYSQL_CONTAINER mysqldump \
        -u $MYSQL_USER \
        -p$MYSQL_PASSWORD \
        --single-transaction \
        --routines \
        --triggers \
        $MYSQL_DATABASE > $BACKUP_DIR/mrdoc_db_$DATE.sql
    echo "数据库备份完成: $BACKUP_DIR/mrdoc_db_$DATE.sql"
else
    echo "警告: MySQL容器未运行，跳过数据库备份"
fi

# 2. 备份媒体文件
echo "正在备份媒体文件..."
if [ -d "./media" ]; then
    tar -czf $BACKUP_DIR/media_$DATE.tar.gz media/
    echo "媒体文件备份完成: $BACKUP_DIR/media_$DATE.tar.gz"
else
    echo "警告: media目录不存在，跳过媒体文件备份"
fi

# 3. 备份配置文件
echo "正在备份配置文件..."
if [ -d "./config" ]; then
    tar -czf $BACKUP_DIR/config_$DATE.tar.gz config/
    echo "配置文件备份完成: $BACKUP_DIR/config_$DATE.tar.gz"
else
    echo "警告: config目录不存在，跳过配置文件备份"
fi

# 4. 备份日志文件（可选）
if [ -d "./log" ] && [ "$(ls -A ./log)" ]; then
    echo "正在备份日志文件..."
    tar -czf $BACKUP_DIR/log_$DATE.tar.gz log/
    echo "日志文件备份完成: $BACKUP_DIR/log_$DATE.tar.gz"
fi

# 5. 清理旧备份（保留最近7天）
echo "正在清理旧备份文件..."
find $BACKUP_DIR -name "*.sql" -type f -mtime +7 -delete
find $BACKUP_DIR -name "*.tar.gz" -type f -mtime +7 -delete

echo "备份完成！备份文件保存在: $BACKUP_DIR"
echo "备份包含:"
ls -la $BACKUP_DIR/*$DATE*

# 6. 备份文件大小统计
echo ""
echo "备份文件大小统计:"
du -sh $BACKUP_DIR/*$DATE* 2>/dev/null || true