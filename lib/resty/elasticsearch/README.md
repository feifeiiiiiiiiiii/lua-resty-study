# lua-resty-elasticsearch

  Copy https://gist.github.com/karmi/b0a9b4c111ed3023a52d

# 用法

```js

# Generate passwords:
#
#     $ printf "nobody:$(openssl passwd -crypt nobody)\n" >> passwords
#     $ printf "all:$(openssl passwd -crypt all)\n"       >> passwords
#     $ printf "user:$(openssl passwd -crypt user)\n"     >> passwords
#     $ printf "admin:$(openssl passwd -crypt admin)\n"   >> passwords
#
# Install the Nginx with Lua support ("openresty"):
#
#     $ wget http://openresty.org/download/ngx_openresty-1.4.3.9.tar.gz
#     $ tar xf ngx_openresty-*
#     $ cd ngx_openresty-*
#     $
#     $ ./configure --with-luajit
#     $ # ./configure --with-luajit --with-cc-opt="-I/usr/local/include" --with-ld-opt="-L/usr/local/lib" # Mac OS X w/ Homebrew
#     $ make && make install
#
# More information: http://openresty.org/#Installation
#
# See the Lua source code in `authorize.lua`
#
# Run:
#
#     $ /usr/local/openresty/nginx/sbin/nginx -p $PWD/nginx/ -c $PWD/nginx_authorize_by_lua.conf

worker_processes  1;

error_log logs/lua.log notice;

events {
  worker_connections 1024;
}

http {
  upstream elasticsearch {
    server 127.0.0.1:9200;
    keepalive 15;
  }

  server {
    listen 8080;

    location / {
      auth_basic           "Protected Elasticsearch";
      auth_basic_user_file passwords;

      access_by_lua_file '../authorize.lua';

      proxy_pass http://elasticsearch;
      proxy_redirect off;
      proxy_buffering off;

      proxy_http_version 1.1;
      proxy_set_header Connection "Keep-Alive";
      proxy_set_header Proxy-Connection "Keep-Alive";
    }

  }
}

```




