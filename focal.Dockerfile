FROM ubuntu:focal

ARG DEBIAN_FRONTEND=noninteractive
ARG NGINX_VERSION=1.19.9
ARG PKG_RELEASE=1
ARG ENABLED_MODULES

RUN set -eu; \
    if [ "$ENABLED_MODULES" = "" ]; then \
        echo "No additional modules enabled, exiting"; \
        exit 1; \
    fi

COPY ./ /modules/

RUN set -eux; \
    apt update; \
    apt install -y --no-install-suggests --no-install-recommends \
        patch make wget mercurial devscripts debhelper dpkg-dev \
        quilt lsb-release build-essential libxml2-utils xsltproc \
        equivs git g++ libparse-recdescent-perl; \
    wget -O- https://hg.nginx.org/xslscript/archive/default.tar.gz | tar -xzvf- -C /usr/local/bin --strip-components=1 xslscript-default/xslscript.pl; \
    hg clone -r "$NGINX_VERSION-$PKG_RELEASE" https://hg.nginx.org/pkg-oss/; \
    cd pkg-oss; \
    mkdir /packages; \
    for module in $ENABLED_MODULES; do \
        echo "Building $module for nginx-$NGINX_VERSION"; \
        if [ -d "/modules/$module" ]; then \
            echo "Building $module from user-supplied sources"; \
            # check if module sources file is there and not empty
            if [ ! -s "/modules/$module/source" ]; then \
                echo "No source file for $module in modules/$module/source, exiting"; \
                exit 1; \
            fi; \
            # some modules require build dependencies
            if [ -f "/modules/$module/build-deps" ]; then \
                echo "Installing $module build dependencies"; \
                apt update && apt install -y --no-install-suggests --no-install-recommends $(cat "/modules/$module/build-deps" | xargs); \
            fi; \
            # if a module has a build dependency that is not in a distro, provide a
            # shell script to fetch/build/install those
            # note that shared libraries produced as a result of this script will
            # not be copied from the builder image to the main one so build static
            if [ -x "/modules/$module/prebuild" ]; then \
                echo "Running prebuild script for $module"; \
                "/modules/$module/prebuild"; \
            fi; \
            build_script=/pkg-oss/build_module.sh; \
            if [ -f "/modules/$module/template" ]; then \
                line=$(grep -n MODULE_SOURCES_ "$build_script" | cut -d : -f 1 | tail -n 1); \
                { head -n "$line" "$build_script"; cat "/modules/$module/template"; tail -n "+$((line + 1))" "$build_script"; } > "$build_script-$module"; \
                build_script="$build_script-$module"; \
                chmod a+rx "$build_script"; \
            fi; \
            "$build_script" -v "$NGINX_VERSION" -f -y -o /packages -n "$module" "$(cat "/modules/$module/source")"; \
        elif make -C /pkg-oss/debian list | grep -P "^$module\s+\d" > /dev/null; then \
            echo "Building $module from pkg-oss sources"; \
            cd /pkg-oss/debian; \
            make "rules-module-$module" "BASE_VERSION=$NGINX_VERSION" "NGINX_VERSION=$NGINX_VERSION"; \
            mk-build-deps --install --tool="apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends --yes" "debuild-module-$module/nginx-$NGINX_VERSION/debian/control"; \
            make "module-$module" "BASE_VERSION=$NGINX_VERSION"; \
            find ../../ -maxdepth 1 -mindepth 1 -type f -name "*.deb" -exec mv -v {} /packages \;; \
        else \
            echo "Don't know how to build $module module, exiting"; \
            exit 1; \
        fi; \
    done
