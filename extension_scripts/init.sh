#!/bin/bash
init_main(){
  echo -e "\033[31m系统基础管理清单:\033[0m\n1.主机名配置\n2.网络配置\nback.返回主菜单\nexit.退出脚本"
  echo -ne "\033[41;37m请选择功能:\033[0m"
  read num
  case $num in
    1)
    hostname_setting
    ;;
    2)
    network_setting
    ;;
    back)
    sh main.sh
    ;;
    exit)
    exit 0
    ;;
    *)
    echo "非法输入,重新选择!"
    init_main
    ;;
  esac
}

hostname_setting(){
  current_name=`hostname`
  echo "当前主机名为:${current_name}"
  read -p "请输入新主机名:" new_hostname
  hostnamectl set-hostname ${new_hostname}
  if [ $? -eq 0 ]; then
    current_name=`hostname`
    echo "成功更改主机名为:${current_name}"
    init_main
  else
    echo "执行脚本出错，请重新执行"
    init_main
  fi
}


network_setting(){
  network_list=`ip addr | sed -r -n 's/^[0-9]+: (.*):.*/\1/p'`
  echo -e "当前存在网卡:\n${network_list}"
  network_method_change
}

network_method_change(){
  read -p "请输入更改网络连接方式:\n1.静态(static)\n2.动态(dhcp)" network_method
  case $network_method in
    1)
    read -p "请输入需要修改网卡配置名称:" network_name
    if [ $network_name != lo ]; then
      network_method=`cat /etc/sysconfig/network-scripts/ifcfg-${network_name} | grep "BOOTPROTO"|awk -F= '{print $2}'`
      if [ $network_method == static  ]; then
        echo "当前网络连接方式为静态(static)"
        read -p "输入IP:" ip
        read -p "输入网关:" gateway
        read -p "输入掩码:" netmask
        read -p "输入dns:" dns
        sed -i 's/BOOTPROTO=.*/BOOTPROTO=static/g'  /etc/sysconfig/network-scripts/ifcfg-${network_name}
        sed -i 's/ONBOOT=.*/ONBOOT=yes/g'  /etc/sysconfig/network-scripts/ifcfg-${network_name}
        sed -i "s/IPADDR=.*/IPADDR=${ip}" /etc/sysconfig/network-scripts/ifcfg-${network_name}
        sed -i "s/GATEWAT=.*/GATEWAY=${gateway}/g" /etc/sysconfig/network-scripts/ifcfg-${network_name}
        sed -i "s/NETMASK=.*/NETMASK=${netmask}/g" /etc/sysconfig/network-scripts/ifcfg-${network_name}
        sed -i "s/DNS1=.*/DNS1=${dns}/g" /etc/sysconfig/network-scripts/ifcfg-${network_name}
        systemctl restart network
        if [ $? -eq 0 ]; then
          echo "网络配置成功,静态==>静态"
          init_main
        else
          echo "执行脚本出错，请重新执行"
          init_main
        fi
      elif [ $network_method == dhcp  ]; then
        echo "当前网络连接方式为动态(dhcp)"
        read -p "输入IP:" ip
        read -p "输入网关:" gateway
        read -p "输入掩码:" netmask
        read -p "输入dns:" dns
        sed -i 's/BOOTPROTO=.*/BOOTPROTO=static/g'  /etc/sysconfig/network-scripts/ifcfg-${network_name}
        sed -i 's/ONBOOT=.*/ONBOOT=yes/g'  /etc/sysconfig/network-scripts/ifcfg-${network_name}
        cat >> /etc/sysconfig/network-scripts/ifcfg-${network_name} <<EOF
IPADDR=${ip}
NETMASK=${netmask}
GATEWAY=${gateway}
DNS1=${dns}
EOF
        systemctl restart network
        if [ $? -eq 0 ]; then
          echo "网络配置成功,动态==>静态"
          init_main
        else
          echo "执行脚本出错，请重新执行"
          init_main
        fi
      else
        echo "识别不出或者未设置网络连接方式"
        init_main
      fi
    elif [ $network_name = lo ]; then
      echo "选择配置网卡为本地回环网卡,不进行配置!"
    else
      echo "未识别出网卡!"
      init_main
    fi

    ;;
    2)
    read -p "请输入需要修改网卡配置名称:" network_name
    if [ $network_name != lo ]; then
      network_method=`cat /etc/sysconfig/network-scripts/ifcfg-${network_name} | grep "BOOTPROTO"|awk -F= '{print $2}'`
      if [ $network_method == static  ]; then
        echo "当前网络连接方式为静态(static)"
        sed -i 's/BOOTPROTO=.*/BOOTPROTO=dhcp/g'  /etc/sysconfig/network-scripts/ifcfg-${network_name}
        sed -i 's/ONBOOT=.*/ONBOOT=yes/g'  /etc/sysconfig/network-scripts/ifcfg-${network_name}
        sed -i '/IPADDR=.*/d' /etc/sysconfig/network-scripts/ifcfg-${network_name}
        sed -i '/NETMASK=.*/d' /etc/sysconfig/network-scripts/ifcfg-${network_name}
        sed -i '/GATEWAY=.*/d' /etc/sysconfig/network-scripts/ifcfg-${network_name}
        sed -i '/DNS.*/d' /etc/sysconfig/network-scripts/ifcfg-${network_name}
        systemctl restart network
        if [ $? -eq 0 ]; then
          echo "网络配置成功,静态==>动态"
          init_main
        else
          echo "执行脚本出错，请重新执行"
          init_main
        fi
      elif [ $network_method == dhcp  ]; then
        echo "当前网络连接方式为动态(dhcp),无需更改状态!"
        init_main 
      else
        echo "识别不出或者未设置网络连接方式"
        init_main
      fi
    elif [ $network_name = lo ]; then
      echo "选择配置网卡为本地回环网卡,不进行配置!"
    else
      echo "未识别出网卡!"
      init_main
    fi
    ;;
    back)
    sh main.sh
    ;;
    exit)
    exit 0
    ;;
    *)
    echo "非法输入,重新选择!"
    init_main
    ;;
  esac
}
