#!/bin/sh

# 生成数据库迁移文件
python /app/MrDoc/manage.py makemigrations &&
# 根据数据库迁移文件执行数据库变更
python /app/MrDoc/manage.py migrate &&
# 重建全文搜索索引
nohup echo y |python /app/MrDoc/manage.py rebuild_index &

# 检查 uwsgi.ini 是否存在
if [ -f /app/MrDoc/config/uwsgi.ini ]; then
    # 启动uwsgi
    uwsgi --ini /app/MrDoc/config/uwsgi.ini
else
    # 如果 uwsgi.ini 不存在，使用 runserver
    echo "uwsgi.ini not found, using runserver instead..."
    python -u /app/MrDoc/manage.py runserver --noreload 0.0.0.0:10086
fi

exec "$@"