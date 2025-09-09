# LDAP Docker 配置指南

## Docker环境变量配置

在使用Docker部署MrDoc并启用LDAP认证时，可以通过环境变量来配置LDAP参数，无需手动修改config.ini文件。

### 支持的LDAP环境变量

```bash
# LDAP基本配置
LDAP_ENABLE=true                              # 启用LDAP认证
LDAP_SERVER_URI=ldap://your-ldap-server:389   # LDAP服务器地址
LDAP_BIND_DN=cn=admin,dc=example,dc=com       # 绑定DN
LDAP_BIND_PASSWORD=your-admin-password        # 绑定密码

# LDAP用户搜索配置
LDAP_USER_BASE_DN=ou=users,dc=example,dc=com  # 用户搜索基础DN
LDAP_USER_SEARCH_FILTER=(uid={username})      # 用户搜索过滤器

# LDAP用户属性映射
LDAP_USER_ATTR_USERNAME=uid                   # 用户名属性
LDAP_USER_ATTR_EMAIL=mail                     # 邮箱属性
LDAP_USER_ATTR_FIRST_NAME=givenName          # 名字属性
LDAP_USER_ATTR_LAST_NAME=sn                  # 姓氏属性
```

### Docker Compose示例

```yaml
version: '3.7'
services:
  mrdoc:
    image: mrdoc:latest
    ports:
      - "10086:10086"
    environment:
      # 数据库配置
      DATABASE_ENGINE: mysql
      DATABASE_NAME: mrdoc
      DATABASE_USER: mrdoc_user
      DATABASE_PASSWORD: mrdoc_password
      DATABASE_HOST: db
      DATABASE_PORT: 3306
      
      # LDAP配置
      LDAP_ENABLE: "true"
      LDAP_SERVER_URI: "ldap://openldap:389"
      LDAP_BIND_DN: "cn=admin,dc=example,dc=com"
      LDAP_BIND_PASSWORD: "adminpassword"
      LDAP_USER_BASE_DN: "ou=users,dc=example,dc=com"
      LDAP_USER_SEARCH_FILTER: "(uid={username})"
      LDAP_USER_ATTR_USERNAME: "uid"
      LDAP_USER_ATTR_EMAIL: "mail"
      LDAP_USER_ATTR_FIRST_NAME: "givenName"
      LDAP_USER_ATTR_LAST_NAME: "sn"
    depends_on:
      - db
      - openldap

  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: root_password
      MYSQL_DATABASE: mrdoc
      MYSQL_USER: mrdoc_user
      MYSQL_PASSWORD: mrdoc_password
    volumes:
      - mysql_data:/var/lib/mysql

  openldap:
    image: osixia/openldap:1.5.0
    environment:
      LDAP_ORGANISATION: "MrDocTest"
      LDAP_DOMAIN: "example.com"
      LDAP_ADMIN_PASSWORD: "adminpassword"
    ports:
      - "389:389"
      - "636:636"

volumes:
  mysql_data:
```

### 构建支持LDAP的Docker镜像

```bash
# 构建镜像
docker build -t mrdoc:ldap .

# 运行容器（使用环境变量配置LDAP）
docker run -d \
  -p 10086:10086 \
  -e LDAP_ENABLE=true \
  -e LDAP_SERVER_URI=ldap://your-ldap-server:389 \
  -e LDAP_BIND_DN=cn=admin,dc=example,dc=com \
  -e LDAP_BIND_PASSWORD=your-password \
  -e LDAP_USER_BASE_DN=ou=users,dc=example,dc=com \
  --name mrdoc \
  mrdoc:ldap
```

### 安全建议

1. **使用LDAPS**：在生产环境中建议使用LDAPS（LDAP over SSL/TLS）：
   ```bash
   LDAP_SERVER_URI=ldaps://your-ldap-server:636
   ```

2. **密码保护**：使用Docker secrets或环境变量文件来保护敏感信息：
   ```bash
   docker run -d \
     --env-file ldap.env \
     --name mrdoc \
     mrdoc:ldap
   ```

3. **网络隔离**：将LDAP服务器和MrDoc放在同一个Docker网络中，避免暴露LDAP端口到外网。

### 故障排除

1. **检查LDAP连接**：
   ```bash
   docker exec mrdoc-container python manage.py shell
   # 在Python shell中测试LDAP连接
   ```

2. **查看日志**：
   ```bash
   docker logs mrdoc-container
   ```

3. **验证配置**：确保LDAP服务器可从容器内访问，检查网络连接和防火墙设置。