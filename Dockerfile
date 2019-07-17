FROM crystallang/crystal:latest

WORKDIR /build/fastpass
COPY shard.lock shard.yml ./
RUN shards install
COPY src src
RUN shards build --production
