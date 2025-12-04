#!/bin/sh

# 设置错误处理
set -e

echo "Starting MrDoc container..."

# 检查并创建必要的目录
mkdir -p /app/MrDoc/config /app/MrDoc/log /app/MrDoc/media /app/MrDoc/static

# 生成数据库迁移文件
echo "Running makemigrations..."
python /app/MrDoc/manage.py makemigrations || true

# 根据数据库迁移文件执行数据库变更
echo "Running migrations..."
python /app/MrDoc/manage.py migrate || true

# 重建全文搜索索引（后台运行）
echo "Rebuilding search index in background..."
nohup sh -c "echo y | python /app/MrDoc/manage.py rebuild_index" > /app/MrDoc/log/rebuild_index.log 2>&1 &

# 检查 uwsgi.ini 是否存在
echo "Checking for uwsgi.ini..."
if [ -f /app/MrDoc/config/uwsgi.ini ]; then
    echo "Found uwsgi.ini, starting with uWSGI..."
    exec uwsgi --ini /app/MrDoc/config/uwsgi.ini
else
    echo "uwsgi.ini not found, starting with Django runserver..."
    exec python -u /app/MrDoc/manage.py runserver --noreload 0.0.0.0:10086
fi