# 配置指南

MrDoc 的配置主要由两个文件管理: `config/config.ini` 和 `MrDoc/settings.py`。

## `config/config.ini`

这个文件包含了基本的站点配置。

*   **[site]**
    *   `debug`: 设置为 `True` 以开启调试模式，`False` 为关闭。

*   **[database]**
    *   `engine`: 数据库类型 (`sqlite`, `mysql`, `postgresql`, `oracle`)。
    *   `name`, `user`, `password`, `host`, `port`: 数据库连接信息。

*   **[locale]**
    *   `language`: 站点语言 (例如 `zh-hans`, `en`)。
    *   `timezone`: 站点时区 (例如 `Asia/Shanghai`)。

*   **[selenium]**
    *   `driver`: Selenium driver 类型 (例如 `Chrome`)。
    *   `driver_path`: `chromedriver` 的绝对路径。

## `MrDoc/settings.py`

这是 Django 的主配置文件，包含了更高级的配置选项。

*   `SECRET_KEY`: Django 的密钥，请务必保密。
*   `ALLOWED_HOSTS`: 允许访问的域名列表。
*   `INSTALLED_APPS`: 项目中启用的 Django 应用。
*   `MIDDLEWARE`: 中间件配置。
*   `TEMPLATES`: 模板配置。
*   `DATABASES`: 数据库配置，从 `config/config.ini` 读取。
*   `CACHES`: 缓存配置。
*   `STATIC_URL`, `STATIC_ROOT`: 静态文件配置。
*   `MEDIA_URL`, `MEDIA_ROOT`: 媒体文件配置。
*   `HAYSTACK_CONNECTIONS`: 全文检索配置。
