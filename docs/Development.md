# 开发指南

欢迎为 MrDoc 做出贡献！本指南将为您提供有关如何为项目做出贡献的信息。

## 开发环境

我们建议使用虚拟环境进行开发。

```bash
# 创建虚拟环境
python -m venv venv

# 激活虚拟环境
source venv/bin/activate  # on Linux/macOS
.\venv\Scripts\activate  # on Windows

# 安装依赖
pip install -r requirements.txt
```

## 编码风格

*   **Python**: 我们遵循 [PEP 8](https://www.python.org/dev/peps/pep-0008/) 编码规范。
*   **Django**: 我们遵循 Django 的编码风格和最佳实践。
*   **JavaScript**: 我们遵循标准的 JavaScript 编码风格。

## 测试

在提交代码之前，请确保运行测试以确保您的更改不会破坏任何现有功能。

```bash
python manage.py test
```

## 技术栈

*   **后端:**
    *   Python 3
    *   Django
    *   Django REST Framework
*   **前端:**
    *   HTML5
    *   CSS3
    *   JavaScript
    *   jQuery
    *   LayUI
    *   Editor.md
    *   Vditor
*   **数据库:**
    *   SQLite
    *   MySQL
    *   PostgreSQL
    *   Oracle
*   **搜索:**
    *   Whoosh
    *   Haystack

## 贡献

我们欢迎任何形式的贡献，包括：

*   报告错误
*   提交功能请求
*   编写或改进文档
*   提交拉取请求
