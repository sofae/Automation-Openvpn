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

增加登陆验证  
server.conf  
reneg-sec 300  
client-connect checkpsw.sh  
client-disconnect checkpsw.sh  

服务重启
systemctl restart openvpn@server.service
  
systemctl stop firewalld  
systemctl disable firewalld  
systemctl mask firewalld  
  
yum install iptables-services  
systemctl enable iptables.service  
systemctl start iptables.service  

echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf  
sysctl -p  
  
iptables -t nat -A POSTROUTING -s 10.20.8.0/24 -o eth0 -j MASQUERADE  
iptables -t nat -A POSTROUTING -s 10.20.8.0/24 -d 172.17.161.0/24 -j MASQUERADE  
iptables -t nat -A POSTROUTING -s 10.20.8.0/24 -d 172.17.16.0/20 -j MASQUERADE  
iptables -t nat -A POSTROUTING -s 10.30.8.0/24 -p udp --dport 53 -o eth0 -j MASQUERADE  
  
iptables -t nat -L -n  
iptables-restore < /etc/iptables.rules  
iptables-save > /etc/iptables.rules  

网段互通  
server.conf  
client-to-client  #客户端互通  
route 192.168.1.0 255.255.255.0 10.50.8.226  #客户端网段声明  
  
ccd/k3s 
ifconfig-push 10.50.8.226 255.255.255.0  #绑定客户端IP  
iroute 192.168.1.0 255.255.255.0  #服务端到客户端路由  
  
iptables -t nat -A POSTROUTING -s 10.50.8.0/24 ! -d 10.50.8.0/24 -j SNAT --to 172.30.32.4  
  
服务端，客户端各自添加路由  
阿里云路由在VPC路由表中添加  
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -j MASQUERADE  
  
iptables 删除单条规则  
iptables -t nat -nL POSTROUTING --line-number  
iptables -t nat -D POSTROUTING 7  
  
QA:  
ping 出现 Destination Host Prohibited  
iptables -t filter -nvL --line-number  
6      759  111K REJECT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            reject-with icmp-host-prohibited  
清除规则  
iptables -t filter -D INPUT 6  
  
  


