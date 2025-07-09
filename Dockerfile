FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    lua5.3 \
    lua5.3-dev \
    libssl-dev \
    unzip \
    git \
    ca-certificates \
    default-libmysqlclient-dev \
    procps \
    && apt-get clean

RUN curl -L -O https://luarocks.org/releases/luarocks-3.9.2.tar.gz && \
    tar zxpf luarocks-3.9.2.tar.gz && \
    cd luarocks-3.9.2 && \
    ./configure --lua-version=5.3 && \
    make && \
    make install && \
    cd .. && rm -rf luarocks-3.9.2*

RUN luarocks install luasec && \
    luarocks install copas && \
    luarocks install luasocket && \
    luarocks install luaossl && \
    luarocks install luafilesystem && \
    luarocks install busted && \
    luarocks install luasql-mysql MYSQL_INCDIR=/usr/include/mysql

WORKDIR /app

COPY . .

CMD ["lua5.3", "luaw.lua"]
