# 自动化部署OPENVPN服务用于企业运维
# Automation Install OpenVPN Server

实现效果:  
拨入openvpn后仅访问公司内网,可通过修改push "route x.x.x.x x.x.x.x"增加访问网段  
访问外网依然使用原本地网络  
  
1、创建checkpsw.sh文件  
添加执行权限  
chmod +x /etc/openvpn/checkpsw.sh  

2、创建用户和密码认证文件  
vi /etc/openvpn/psw-file  
admin 123456 (前面是用户 后面是密码)  
  
注：psw-file的权限  
chmod 400 /etc/openvpn/psw-file  
chown nobody.nobody /etc/openvpn/psw-file  
  
分配固定IP  
vi server.conf  
client-config-dir ccd  
mkdir ccd  
vi ccd/user  
ifconfig-push 10.168.168.168 255.255.255.0  
  
服务重启
systemctl restart openvpn@server.service

iptables -t nat -A POSTROUTING -s 10.20.8.0/24 -o eth0 -j MASQUERADE  

  
iptables –t nat –L –n  
iptables-restore < /etc/iptables.rules  
iptables-save > /etc/iptables.rules  
