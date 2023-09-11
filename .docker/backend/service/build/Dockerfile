FROM registry.cn-hangzhou.aliyuncs.com/alomerry/base-golang:1.21 as build

EXPOSE 8091
ARG rpcname
WORKDIR /app/${rpcname}

COPY scripts/start /etc/service/${rpcname}/run
COPY ${rpcname}/conf /app/${rpcname}/conf
COPY ${rpcname}/assets /app/${rpcname}/assets
COPY ${rpcname}/health_check /app/${rpcname}/
COPY ${rpcname}/ping /app/${rpcname}/
COPY ${rpcname}/${rpcname} /app/${rpcname}/

