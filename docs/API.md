# REST API

MrDoc 提供了一套 RESTful API，允许您通过编程方式与您的文档进行交互。API 使用基于 Token 的身份验证。

## 身份验证

所有 API 请求都需要一个 `token` 参数，该参数是用户的唯一身份标识。您可以在您的个人资料页面中生成和管理您的 Token。

**请求示例:**

```
GET /api/get_projects/?token=YOUR_TOKEN
```

## API 端点

以下是可用的 API 端点列表:

### Token

*   **`GET /api/manage_token/`**: 获取当前用户的 Token。
*   **`POST /api/manage_token/`**: 生成一个新的 Token。
*   **`GET /api/check_token/`**: 检查 Token 是否有效。

### 文集 (Projects)

*   **`GET /api/get_projects/`**: 获取用户有权访问的文集列表。
*   **`GET /api/get_project/`**: 获取单个文集的详细信息。
*   **`POST /api/create_project/`**: 创建一个新的文集。

### 文档 (Documents)

*   **`GET /api/get_docs/`**: 获取指定文集下的文档列表。
*   **`GET /api/get_level_docs/`**: 获取文集的层级文档列表。
*   **`GET /api/get_self_docs/`**: 获取用户自己的所有文档列表。
*   **`GET /api/get_doc/`**: 获取单篇文档的详细信息。
*   **`GET /api/get_doc_previous_next/`**: 获取文档的上一篇和下一篇文档。
*   **`POST /api/create_doc/`**: 创建一篇新的文档。
*   **`POST /api/modify_doc/`**: 修改一篇现有的文档。
*   **`POST /api/delete_doc/`**: 删除一篇文档 (软删除)。

### 图片

*   **`POST /api/upload_img/`**: 上传图片。
*   **`POST /api/upload_img_url/`**: 从 URL 上传图片。
