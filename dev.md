# something for developing

## 免密登录原理

### ssh登录提供两种认证方式

- 口令(密码)认证方式
- 和密钥认证方式

### 使用密钥登录分为3步： 

1. 生成密钥（公钥与私钥）； 
2. 放置公钥到服务器~/.ssh/authorized_key文件中； 
3. 配置ssh客户端使用密钥登录。

例子：          

```    
     192.168.1.101           ----------登录--------->   192.168.1.100
1.   生成公钥私钥对
2.                                                      公钥加入authorized_keys
3.   登录
4.   (随机字符串)             <-------随机字符串------    (随机字符串)
5.   私钥加密后的字符串        -----私钥加密字符串----->    使用保存的公钥解密
6.                                                       解密成功，允许登录
```

### 服务端配置

查看ssh的配置文件。

```
sudo vim /etc/ssh/sshd_config
```

```
RSAAuthentication yes 
PubkeyAuthentication yes 
AuthorizedKeysFile %h/.ssh/authorized_keys

#为了安全性，可以修改SSH端口
Port 222

#禁用root账户登录，非必要，但为了安全性，请配置
PermitRootLogin no

#有了证书登录了，就禁用密码登录吧，安全要紧
PasswordAuthentication no123456789101112
```

```
sudo service ssh restart
```