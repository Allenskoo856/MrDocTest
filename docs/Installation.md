# 安装指南

本指南将引导您完成 MrDoc 的安装和配置过程。

## 依赖

*   Python 3.6+
*   pip

## 安装步骤

1.  **克隆仓库:**

    ```bash
    git clone https://github.com/zmister2016/MrDoc.git
    cd MrDoc
    ```

2.  **安装依赖:**

    使用 pip 安装所需的 Python 包:

    ```bash
    pip install -r requirements.txt
    ```

3.  **数据库初始化:**

    创建数据库表结构:

    ```bash
    python manage.py makemigrations
    python manage.py migrate
    ```

4.  **创建超级用户:**

    创建一个管理员账号来管理应用:

    ```bash
    python manage.py createsuperuser
    ```

5.  **运行开发服务器:**

    启动 Django 开发服务器:

    ```bash
    python manage.py runserver
    ```

    应用将在 `http://127.0.0.1:8000/` 上可用。

## Docker 部署

您也可以使用 Docker Compose 来部署 MrDoc。

1.  **部署:**

    ```bash
    git clone https://gitee.com/zmister/mrdoc-install.git && cd mrdoc-install && chmod +x docker-install.sh && ./docker-install.sh
    ```

2.  **更新:**

    运行 `docker-update.sh`。
