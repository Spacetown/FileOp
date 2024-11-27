ARG DOCKER_OS=debian:bookworm

FROM $DOCKER_OS

COPY scripts/container.setup.sh /tmp/container.setup.sh 

RUN --mount=type=cache,target=/var/cache/apt <<EOS
/tmp/container.setup.sh
EOS
