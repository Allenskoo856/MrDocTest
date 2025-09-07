# 软件架构

MrDoc 采用经典的 Django MTV (Model-Template-View) 架构。项目被划分为多个独立的 Django 应用，每个应用负责一部分特定的功能。

## 应用 (Apps)

*   **`app_admin`**: 负责站点的后台管理功能，包括用户管理、站点设置、权限控制等。
*   **`app_doc`**: 项目的核心应用，处理所有与文档、项目、图片和附件相关的功能。这包括文档的创建、编辑、阅读、版本控制和协作。
*   **`app_api`**: 提供一个 RESTful API，允许第三方应用与 MrDoc 进行交互。API 包括了对文档、项目、图片等资源的访问。

## 核心组件

*   **`MrDoc/settings.py`**: Django 项目的主配置文件。
*   **`MrDoc/urls.py`**: 项目的主路由文件，将 URL 请求分发到各个应用。
*   **`manage.py`**: Django 的命令行工具，用于执行各种管理任务。

## 数据模型

MrDoc 的数据模型定义在各个应用的 `models.py` 文件中。主要的模型包括：

*   **`User`**: Django 内置的用户模型。
*   **`Project`**: 文档项目。
*   **`Doc`**: 文档。
*   **`DocHistory`**: 文档的历史版本。
*   **`Image`**: 上传的图片。
*   **`Attachment`**: 上传的附件。
