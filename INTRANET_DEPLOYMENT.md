# 内网部署检查清单

## 已完成的修改

### 1. 禁用版本检查更新功能
- **文件**: `app_admin/views.py`
- **修改**: `check_update()` 函数已禁用网络请求，返回固定版本号
- **影响**: 后台管理页面不再尝试联网检查更新

### 2. 替换CDN资源为本地资源

#### jQuery CDN替换
已将以下文件中的CDN jQuery替换为本地版本：
- `template/forget_pwd.html` 
- `template/403.html`
- `template/app_api/api404.html`

使用本地资源：`{% static 'jquery/jquery.min.js' %}`

#### IE兼容脚本CDN禁用
以下文件中的IE兼容CDN脚本已注释（内网环境通常不需要支持旧IE浏览器）：
- `template/app_doc/share/share_doc.html`
- `template/app_doc/tag_doc_base.html`
- `template/app_doc/editor/create_base.html`
- `template/app_doc/docs_base.html`
- `template/app_doc/diff_doc.html`

注释的CDN链接：
- `https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js`
- `https://oss.maxcdn.com/libs/respond.js/1.3.0/respond.min.js`

### 3. 屏蔽的外部链接

#### 用户中心菜单
已在 `app_doc/views_user.py` 中注释掉以下外部链接：
- 客户端下载菜单（gitee.com链接）
- 使用帮助菜单（doc.mrdoc.pro链接）

## 其他外部资源说明

### 仅用于展示的外部链接（不影响功能）

#### 1. 备案号链接
以下文件包含工信部备案查询链接（仅展示用，可选择性保留或删除）：
- `template/login.html` - `http://beian.miit.gov.cn/`
- `template/register.html` - `http://beian.miit.gov.cn/`
- `template/ldap_login.html` - `http://beian.miit.gov.cn/`
- `template/app_doc/foot_base.html` - `http://beian.miit.gov.cn/`

#### 2. IconFont演示页面
`static/iconFont/demo_index.html` - 阿里巴巴图标库演示页，仅供参考，不影响系统运行

#### 3. 搜索页面作者信息
`template/app_doc/search.html` - 包含原作者链接，仅展示用

#### 4. SVG xmlns属性
以下是SVG/HTML标准命名空间声明，不是外部资源请求：
- `xmlns="http://www.w3.org/2000/svg"`
- `xmlns="http://www.w3.org/1999/xhtml"`
- 这些是XML命名空间标识符，不会发起网络请求

### 代码中的URL字符串（非网络请求）

以下是代码注释和文档中的URL，不会发起实际网络请求：
- Django官方文档链接（注释中）
- API示例URL（127.0.0.1）
- 配置文件中的localhost相关配置

## 网络请求检查

### 已禁用的网络请求
1. ✅ 版本更新检查 (`check_update` 函数)

### 仍然存在的网络功能（按需使用）
以下功能在用户主动触发时才会发起网络请求：

1. **图片上传功能** (`app_doc/util_upload_img.py`)
   - 当用户粘贴外部图片URL时会下载图片
   - `requests.get(url)` 用于下载远程图片
   - **建议**: 内网环境下，建议用户仅上传本地图片

2. **导入工具箱链接**
   - `template/app_doc/manage/manage_project_import.html`
   - 包含gitee.com的导入工具箱链接
   - **说明**: 仅为文字提示，不会自动访问

## 内网部署建议

### 1. 完全离线部署
如需完全离线部署，建议：
- 所有静态资源已本地化（已完成）
- 数据库使用本地MySQL/PostgreSQL/SQLite
- 禁用LDAP或使用内网LDAP服务器

### 2. 用户指导
告知用户在内网环境下：
- 不要粘贴外部图片链接，使用本地上传
- 文档分享功能仅限内网用户访问
- 不使用第三方登录功能

### 3. 防火墙配置
可选择性地在防火墙层面：
- 阻止应用服务器向外网发起HTTP/HTTPS请求
- 仅允许访问内网LDAP服务器（如需要）

## 验证方法

### 检查网络请求
```bash
# 监控应用的网络连接
netstat -an | grep ESTABLISHED | grep <应用端口>

# 使用tcpdump监控HTTP请求
tcpdump -i any -n 'tcp port 80 or tcp port 443'
```

### 测试内网环境
1. 断开服务器外网连接
2. 访问各个功能页面
3. 确认所有功能正常工作（除了需要外网的图片下载功能）

## 总结

✅ **已完成的内网优化**:
1. 禁用版本更新检查
2. 所有CDN资源替换为本地资源
3. 移除不必要的外部菜单链接
4. 注释IE兼容性CDN脚本

⚠️ **注意事项**:
1. 图片粘贴外部URL功能会尝试下载，建议用户仅使用本地上传
2. 备案号链接仅为展示，不影响功能
3. SVG命名空间不是网络请求

✨ **系统已适配纯内网部署，所有核心功能可在无外网环境下正常运行**
