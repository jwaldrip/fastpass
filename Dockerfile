FROM crystallang/crystal:0.27.0

WORKDIR build-dir/fastpass
COPY shard.lock shard.yml ./
RUN shards install
COPY src src
RUN shards build --production

CMD ./bin/fastpass server
