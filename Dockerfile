FROM crystallang/crystal:latest as builder

WORKDIR /build
COPY shard.lock shard.yml ./
RUN shards install
COPY src src
RUN shards build --production

FROM crystallang/crystal:latest

COPY --from=builder /build/bin/fastpass /usr/local/bin/fastpass