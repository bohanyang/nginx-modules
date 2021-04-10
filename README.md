# APT Repository of some NGINX dynamic modules

Only compatible with the [official NGINX packages for Debian/Ubuntu](https://nginx.org/en/linux_packages.html#Debian).

Only mainline versions are supported. **Stable versions are not supported.**

The build script in the Dockerfile is copied from [nginxinc/docker-nginx](https://github.com/nginxinc/docker-nginx/tree/master/modules).

### Ubuntu 20.04 (focal)

```sh
echo 'deb [trusted=yes] https://packages.bohan.co/nginx-modules focal/' | sudo tee /etc/apt/sources.list.d/bohan-nginx-modules.list
sudo apt update
```

### Debian 10 (buster)

```sh
echo 'deb [trusted=yes] https://packages.bohan.co/nginx-modules buster/' | sudo tee /etc/apt/sources.list.d/bohan-nginx-modules.list
sudo apt update
```

## Available Packages

* `nginx-module-brotli` - [ngx_brotli](https://github.com/google/ngx_brotli)
* `nginx-module-geoip2` - [ngx_http_geoip2_module](https://github.com/leev/ngx_http_geoip2_module)
* `nginx-module-ipdbhttp` - [ngx_http_ipdb_module](https://github.com/vislee/ngx_http_ipdb_module)
* `nginx-module-ipdbstream` - [ngx_stream_ipdb_module](https://github.com/vislee/ngx_stream_ipdb_module)
