# coding:utf-8
"""
LDAP认证后端
实现Django的自定义认证后端，用于LDAP用户认证
"""
import ldap3
from django.contrib.auth.backends import BaseBackend
from django.contrib.auth.models import User
from django.conf import settings
from configparser import ConfigParser
from loguru import logger
import os


class LDAPBackend(BaseBackend):
    """
    LDAP认证后端
    """
    
    def __init__(self):
        """初始化LDAP配置"""
        self.config = ConfigParser()
        config_path = os.path.join(settings.BASE_DIR, 'config', 'config.ini')
        self.config.read(config_path, encoding='utf-8')
        
        # LDAP配置，优先使用环境变量，其次使用配置文件
        self.server_uri = os.getenv('LDAP_SERVER_URI') or self.config.get('ldap', 'server_uri', fallback='ldap://localhost:389')
        self.bind_dn = os.getenv('LDAP_BIND_DN') or self.config.get('ldap', 'bind_dn', fallback='')
        self.bind_password = os.getenv('LDAP_BIND_PASSWORD') or self.config.get('ldap', 'bind_password', fallback='')
        self.user_base_dn = os.getenv('LDAP_USER_BASE_DN') or self.config.get('ldap', 'user_base_dn', fallback='')
        self.user_search_filter = os.getenv('LDAP_USER_SEARCH_FILTER') or self.config.get('ldap', 'user_search_filter', fallback='(uid={username})')
        
        # 用户属性映射
        self.attr_username = os.getenv('LDAP_USER_ATTR_USERNAME') or self.config.get('ldap', 'user_attr_username', fallback='uid')
        self.attr_email = os.getenv('LDAP_USER_ATTR_EMAIL') or self.config.get('ldap', 'user_attr_email', fallback='mail')
        self.attr_first_name = os.getenv('LDAP_USER_ATTR_FIRST_NAME') or self.config.get('ldap', 'user_attr_first_name', fallback='givenName')
        self.attr_last_name = os.getenv('LDAP_USER_ATTR_LAST_NAME') or self.config.get('ldap', 'user_attr_last_name', fallback='sn')

    def authenticate(self, request, username=None, password=None, **kwargs):
        """
        LDAP认证方法
        
        Args:
            request: HTTP请求对象
            username: 用户名
            password: 密码
            **kwargs: 其他参数
            
        Returns:
            User对象或None
        """
        if not username or not password:
            return None
            
        try:
            # 检查是否启用LDAP认证（优先使用环境变量）
            enable_ldap_env = os.getenv('LDAP_ENABLE')
            if enable_ldap_env is not None:
                enable_ldap = enable_ldap_env.lower() in ('true', '1', 'yes', 'on')
            else:
                enable_ldap = self.config.getboolean('ldap', 'enable_ldap', fallback=False)
                
            if not enable_ldap:
                return None
                
            # 创建LDAP服务器连接
            server = ldap3.Server(self.server_uri, get_info=ldap3.ALL)
            
            # 使用管理员账户连接LDAP进行用户搜索
            conn = ldap3.Connection(server, self.bind_dn, self.bind_password, auto_bind=True)
            
            # 搜索用户
            search_filter = self.user_search_filter.format(username=username)
            conn.search(
                self.user_base_dn,
                search_filter,
                attributes=[self.attr_username, self.attr_email, 
                           self.attr_first_name, self.attr_last_name]
            )
            
            if not conn.entries:
                logger.info(f"LDAP用户 {username} 不存在")
                return None
                
            # 获取用户DN
            user_entry = conn.entries[0]
            user_dn = user_entry.entry_dn
            
            # 关闭管理员连接
            conn.unbind()
            
            # 使用用户凭据进行认证
            user_conn = ldap3.Connection(server, user_dn, password)
            
            if not user_conn.bind():
                logger.info(f"LDAP用户 {username} 密码错误")
                return None
                
            # 认证成功，获取用户信息
            user_info = {
                'username': username,
                'email': getattr(user_entry, self.attr_email, [username + '@example.com'])[0] if hasattr(user_entry, self.attr_email) else username + '@example.com',
                'first_name': getattr(user_entry, self.attr_first_name, [''])[0] if hasattr(user_entry, self.attr_first_name) else '',
                'last_name': getattr(user_entry, self.attr_last_name, [''])[0] if hasattr(user_entry, self.attr_last_name) else ''
            }
            
            # 关闭用户连接
            user_conn.unbind()
            
            # 获取或创建Django用户
            user = self.get_or_create_user(user_info)
            
            logger.info(f"LDAP用户 {username} 认证成功")
            return user
            
        except Exception as e:
            logger.error(f"LDAP认证失败: {e}")
            return None

    def get_or_create_user(self, user_info):
        """
        获取或创建Django用户
        
        Args:
            user_info: 用户信息字典
            
        Returns:
            User对象
        """
        try:
            # 尝试获取现有用户
            user = User.objects.get(username=user_info['username'])
            
            # 更新用户信息
            user.email = user_info['email']
            user.first_name = user_info['first_name']
            user.last_name = user_info['last_name']
            user.is_active = True
            user.save()
            
        except User.DoesNotExist:
            # 创建新用户 - 权限默认为普通用户
            user = User.objects.create_user(
                username=user_info['username'],
                email=user_info['email'],
                first_name=user_info['first_name'],
                last_name=user_info['last_name'],
                is_staff=False,  # 不是管理员
                is_superuser=False,  # 不是超级用户
                is_active=True,
                password=None  # LDAP用户不设置本地密码
            )
            logger.info(f"创建LDAP用户: {user_info['username']}")
            
        return user

    def get_user(self, user_id):
        """
        根据用户ID获取用户对象
        
        Args:
            user_id: 用户ID
            
        Returns:
            User对象或None
        """
        try:
            return User.objects.get(pk=user_id)
        except User.DoesNotExist:
            return None