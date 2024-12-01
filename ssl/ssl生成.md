生成带有 SAN（Subject Alternative Name）的 HTTPS SSL 证书可以通过 OpenSSL 完成。以下是详细的步骤，包括创建 CA、生成服务器证书请求（CSR）、配置 SAN 并签发证书。

### 步骤 1：准备环境

确保你已经安装了 OpenSSL，并且有足够的权限来创建和管理证书文件。

### 步骤 2：创建根 CA

#### 创建 CA 私钥

```bash
openssl genrsa -aes256 -out ca.key 4096
```

这将创建一个受密码保护的 4096 位私钥。如果你不希望私钥受密码保护，可以省略 `-aes256` 参数。

#### 创建自签名 CA 证书

```bash
openssl req -x509 -new -nodes -key ca.key \
    -sha256 -days 3650 \
    -out ca.crt \
    -subj "/C=CN/ST=Beijing/L=Beijing/O=qidaren/OU=IT Department/CN=drlg.b.cc"
```

### 步骤 3：创建服务器私钥和 CSR

#### 创建服务器私钥

```bash
openssl genrsa -out drlg.b.cc.key 2048
```

#### 创建 CSR

在创建 CSR 时，你需要指定一个配置文件来包含 SAN 配置。创建一个名为 `openssl.cnf` 的配置文件，内容如下：

```ini
[ req ]
default_bits       = 2048
distinguished_name = req_distinguished_name
req_extensions     = req_ext

[ req_distinguished_name ]
C  = CN
ST = Beijing
L  = Beijing
O  = qidaren
OU = IT Department
CN = drlg.b.cc

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = drlg.b.cc
DNS.2 = *.drlg.b.cc  # 如果需要通配符支持
```

使用此配置文件生成 CSR：

```bash
openssl req -new -key drlg.b.cc.key -out drlg.b.cc.csr -config openssl.cnf
```

### 步骤 4：签发带 SAN 的服务器证书

使用 CA 私钥和证书来签发服务器证书，并确保包含 SAN：

```bash
openssl x509 -req -in drlg.b.cc.csr \
    -CA ca.crt -CAkey ca.key \
    -CAcreateserial \
    -out drlg.b.cc.crt \
    -days 365 \
    -extfile openssl.cnf \
    -extensions req_ext
```

### 步骤 5：验证新证书

确认新证书是否正确包含了 SAN：

```bash
openssl x509 -in drlg.b.cc.crt -text -noout | grep -A1 "Subject Alternative Name"
```

你应该看到类似如下的输出，表明 SAN 已经被正确添加：

```
X509v3 Subject Alternative Name:
    DNS:drlg.b.cc, DNS:*.drlg.b.cc
```

### 步骤 6：部署证书

将生成的 `.crt` 和 `.key` 文件部署到你的 Web 服务器中，并更新服务器配置以使用这些文件。

#### 对于 Nginx

编辑你的 Nginx 配置文件，添加或修改以下指令：

```nginx
server {
    listen 443 ssl;
    server_name drlg.b.cc;

    ssl_certificate /path/to/drlg.b.cc.crt;
    ssl_certificate_key /path/to/drlg.b.cc.key;
    ssl_trusted_certificate /path/to/ca.crt;  # 如果适用

    # 其他配置...
}
```

重启 Nginx 服务以使更改生效：

```bash
sudo systemctl restart nginx
```

#### 对于 Apache

编辑你的 Apache 配置文件，添加或修改以下指令：

```apache
<VirtualHost *:443>
    ServerName drlg.b.cc
    SSLEngine on
    SSLCertificateFile /path/to/drlg.b.cc.crt
    SSLCertificateKeyFile /path/to/drlg.b.cc.key
    SSLCertificateChainFile /path/to/ca.crt  # 如果适用

    # 其他配置...
</VirtualHost>
```

重启 Apache 服务以使更改生效：

```bash
sudo systemctl restart apache2
```

通过以上步骤，你应该能够成功生成并部署一个带有 SAN 的 HTTPS SSL 证书，从而确保浏览器能够正确验证域名与证书的匹配性，并消除“此服务器无法证实它就是 drlg.b.cc”的警告。如果遇到任何问题，请仔细检查每一步骤，确保所有文件路径和配置都正确无误。