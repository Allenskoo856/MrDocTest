# 项目API

<cite>
**本文档引用的文件**   
- [views_app.py](file://app_api/views_app.py)
- [serializers_app.py](file://app_api/serializers_app.py)
- [models.py](file://app_doc/models.py)
- [urls.py](file://app_api/urls_app.py)
- [pro_list.html](file://template/app_doc/pro_list.html)
- [manage_project_options.html](file://template/app_doc/manage/manage_project_options.html)
- [manage_project_collaborator.html](file://template/app_doc/manage/manage_project_collaborator.html)
</cite>

## 目录
1. [项目API](#项目api)
2. [CRUD操作](#crud操作)
3. [序列化规则](#序列化规则)
4. [权限控制机制](#权限控制机制)
5. [分页、过滤与排序](#分页过滤与排序)
6. [特殊操作](#特殊操作)
7. [错误处理](#错误处理)

## CRUD操作

项目API支持创建、读取、更新和删除（CRUD）操作，通过HTTP方法和URL模式进行交互。

### 创建项目
- **HTTP方法**: POST
- **URL模式**: `/api/project/`
- **请求参数**:
  - `pname`: 项目名称（必填）
  - `desc`: 项目描述
  - `role`: 项目权限（0: 公开, 1: 私密, 2: 指定用户可见, 3: 访问码可见）

**示例请求**:
```javascript
$.ajax({
    url: "{% url 'create_project' %}",
    type: 'post',
    data: {
        'pname': $("#pname").val(),
        'desc': $("#desc").val(),
        'role': $("input[name=project-role]:checked").val(),
    },
    success: function(r) {
        if (r.status) {
            window.location.reload();
        } else {
            layer.msg(r.data);
        }
    }
});
```

### 获取项目列表
- **HTTP方法**: GET
- **URL模式**: `/api/project/`
- **查询参数**:
  - `kw`: 搜索关键词
  - `role`: 筛选条件
  - `sort`: 排序方式

### 更新项目
- **HTTP方法**: PUT
- **URL模式**: `/api/project/`
- **查询参数**:
  - `id`: 项目ID
- **请求参数**:
  - `name`: 新的项目名称
  - `desc`: 新的项目描述
  - `role`: 新的项目权限
  - `role_value`: 权限值

### 删除项目
- **HTTP方法**: DELETE
- **URL模式**: `/api/project/`
- **查询参数**:
  - `id`: 项目ID

**Section sources**
- [views_app.py](file://app_api/views_app.py#L320-L427)

## 序列化规则

`ProjectSerializer` 负责项目数据的序列化和反序列化。

### 字段定义
- `create_time`: 创建时间，格式为 `YYYY-MM-DD HH:MM`
- `doc_total`: 文档总数，通过 `get_doc_total` 方法计算
- `username`: 创建者用户名，通过 `get_username` 方法获取

### 序列化方法
```python
def get_username(self, obj):
    return obj.create_user.username

def get_doc_total(self, obj):
    return Doc.objects.filter(top_doc=obj.id).count()
```

**Section sources**
- [serializers_app.py](file://app_api/serializers_app.py#L40-L53)

## 权限控制机制

项目权限控制机制确保只有授权用户可以访问和操作项目。

### 权限级别
- **项目所有者**: 可以进行所有操作
- **协作者**: 根据协作模式有不同的访问级别
  - 0: 可新建文档，可修改、删除自己新建的文档
  - 1: 可操作所有文档

### 权限设置
- **公开 (0)**: 所有用户可见
- **私密 (1)**: 仅项目所有者可见
- **指定用户可见 (2)**: 仅指定用户可见
- **访问码可见 (3)**: 需要访问码才能查看

**Section sources**
- [models.py](file://app_doc/models.py#L5-L32)
- [manage_project_options.html](file://template/app_doc/manage/manage_project_options.html#L101-L125)

## 分页、过滤与排序

### 分页
使用Django的 `Paginator` 进行分页处理，每页显示12个项目。

**示例代码**:
```python
paginator = Paginator(project_list, 12)
page = request.GET.get('page', 1)
try:
    projects = paginator.page(page)
except PageNotAnInteger:
    projects = paginator.page(1)
except EmptyPage:
    projects = paginator.page(paginator.num_pages)
```

### 过滤
根据用户身份和筛选条件过滤项目列表。

**过滤逻辑**:
- 认证用户: 可见公开、私密、指定用户可见和协作文集
- 游客: 仅可见公开和访问码可见的文集

### 排序
支持按创建时间排序，可选择升序或降序。

**Section sources**
- [views.py](file://app_doc/views.py#L246-L352)
- [pro_list.html](file://template/app_doc/pro_list.html#L305-L330)

## 特殊操作

### 项目转让
允许项目所有者将项目转让给其他用户。

### 协作配置
管理项目的协作者，设置协作模式。

**协作模式**:
- 0: 可新建文档，可修改、删除自己新建的文档
- 1: 可操作所有文档

**示例界面**:
```html
<td>
    {% if colla.role == 0 %}
    {% trans "新建文档，修改、删除新建的文档" %}
    {% else %}
    {% trans "可操作所有文档" %}
    {% endif %}
</td>
```

### 权限管理
修改项目的访问权限，包括公开、私密、指定用户可见和访问码可见。

**Section sources**
- [manage_project_collaborator.html](file://template/app_doc/manage/manage_project_collaborator.html#L61-L81)

## 错误处理

### 常见错误
- **项目名称冲突**: 返回错误码5，提示"参数不正确"
- **权限不足**: 返回错误码2，提示"非法请求"
- **资源未找到**: 返回错误码1，提示"资源未找到"
- **系统异常**: 返回错误码4，提示"系统异常请稍后再试"
- **未登录**: 返回错误码6，提示"请登录后操作"

### 错误响应格式
```json
{
    "code": 5,
    "data": "参数不正确"
}
```

**Section sources**
- [views_app.py](file://app_api/views_app.py#L320-L427)