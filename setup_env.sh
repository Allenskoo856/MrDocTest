#!/bin/bash
# MySQL 环境变量设置
export PATH="/opt/homebrew/opt/mysql@8.0/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/mysql@8.0/lib"
export CPPFLAGS="-I/opt/homebrew/opt/mysql@8.0/include"

echo "MySQL 环境变量已设置"
echo "PATH: $PATH"
echo "LDFLAGS: $LDFLAGS" 
echo "CPPFLAGS: $CPPFLAGS"