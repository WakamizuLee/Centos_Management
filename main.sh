#!/bin/bash
#author: wakamizu lee
#mail: wakamizulee@163.com
#createdate: 2020.11.16
#changedate: 2020.11.16
source ./extension_scripts/init.sh
echo -e "\033[31m功能清单:\033[0m\n1.系统基础管理\nexit.退出脚本"
echo -ne "\033[41;37m请选择功能:\033[0m"
read num 
case $num in
  1) 
  init_main 
  ;;
  exit) 
  exit 0
  ;;
  *) 
  echo "非法输入,重新选择!"
  sh main.sh
  ;;
esac 
