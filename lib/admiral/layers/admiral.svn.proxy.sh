#! /bin/sh

cat <<EOF >> /etc/subversion/servers
http-proxy-host = $svn_proxy_host
http-proxy-port = $svn_proxy_port
http-proxy-username = $svn_proxy_user
http-proxy-password = $svn_proxy_password
EOF

