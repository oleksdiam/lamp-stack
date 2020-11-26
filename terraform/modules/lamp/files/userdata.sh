#!/bin/bash -xe
yum update -y
yum install -y mc httpd

systemctl start httpd.service
systemctl enable httpd.service

amazon-linux-extras install -y php7.4

yum -y install amazon-efs-utils

mount -t efs -o tls fs-ced67c3b:/ /var/www/html       # encryption in transit

cat << EOF >> /etc/fstab
fs-ced67c3b:/ /var/www/html efs tls,_netdev 0  0      # encryption in transit
EOF

cat <<- EOF > /etc/httpd/conf.d/vhosts.conf
<VirtualHost *:80>
ServerAdmin <strong>admin@odiam-wp.support-coe.com</strong>
DocumentRoot /var/www/html/wordpress
ServerName <strong>odiam-wp.support-coe.com</strong>
ServerAlias <strong>www.odiam-wp.support-coe.com</strong>
ErrorLog /var/log/httpd/odiam-wp-error-log
CustomLog /var/log/httpd/odiam-wp-acces-log common
</VirtualHost>
EOF

systemctl restart httpd.service