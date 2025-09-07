# MrDoc Project Analysis

## Project Overview

MrDoc is a web-based document management system built with Python and the Django framework. It serves as a private, self-hostable solution for individuals and small teams to manage notes, documents, and knowledge. The project includes a rich feature set, such as a Markdown editor, document versioning, project collaboration, and a REST API.

**Key Technologies:**

*   **Backend:** Python, Django, Django REST Framework
*   **Frontend:** HTML, CSS, JavaScript (jQuery, LayUI, and other libraries)
*   **Database:** SQLite (default), MySQL, PostgreSQL, Oracle
*   **Search:** Whoosh, Haystack
*   **Dependencies:** See `requirements.txt` for a full list.

**Architecture:**

The project is structured into three main Django apps:

*   `app_admin`: Handles administrative tasks and site management.
*   `app_doc`: Core application for managing documents, projects, and related features.
*   `app_api`: Provides a RESTful API for interacting with the system.

## Building and Running

### 1. Installation

Install the required Python packages using pip:

```bash
pip install -r requirements.txt
```

### 2. Database Initialization

Create the database schema by running the following commands:

```bash
python manage.py makemigrations
python manage.py migrate
```

### 3. Create a Superuser

Create an administrator account to manage the application:

```bash
python manage.py createsuperuser
```

### 4. Running the Development Server

Start the Django development server:

```bash
python manage.py runserver
```

The application will be accessible at `http://127.0.0.1:8000/`.

## Development Conventions

*   **Code Style:** The project follows standard Python and Django coding conventions.
*   **Configuration:** Project settings are managed in `MrDoc/settings.py` and `config/config.ini`.
*   **Internationalization:** The project supports multiple languages, with translation files located in the `locale` directory.
*   **Static Files:** Static assets (CSS, JavaScript, images) are located in the `static` directory.
*   **Templates:** Django templates are located in the `template` directory.

## 回复
gemini大模型的所有回复均通过简体中文的形式进行回复


## 编码风格

*   **Python**: 我们遵循 [PEP 8](https://www.python.org/dev/peps/pep-0008/) 编码规范。
*   **Django**: 我们遵循 Django 的编码风格和最佳实践。
*   **JavaScript**: 我们遵循标准的 JavaScript 编码风格。

## 测试

在提交代码之前，请确保运行测试以确保您的更改不会破坏任何现有功能。
