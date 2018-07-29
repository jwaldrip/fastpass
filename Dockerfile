FROM crystallang/crystal

WORKDIR build-dir/fastpass
COPY shard.lock shard.yml ./
RUN shards install
COPY src src
RUN shards build --release

CMD ./bin/fastpass server
