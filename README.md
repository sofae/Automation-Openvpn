# OpenVPN-Server一键式部署
Automation Install OpenVPN Server

1、创建checkpsw.sh文件
添加执行权限
chmod +x /etc/openvpn/checkpsw.sh

2、创建用户和密码认证文件
vim /etc/openvpn/psw-file
admin 123456 (前面是用户 后面是密码)

注：psw-file的权限
chmod 400 /etc/openvpn/psw-file
chown nobody.nobody /etc/openvpn/psw-file
 
3、修改客户端配置文件：client.ovpn
再添加这一行，就会提示输入用户名和密码
auth-user-pass
