#!/bin/bash
# Build script for Linux targets using vcpkg with fallback support

# 如果当前目录下有Dockerfile.nos，则使用Dockerfile.nos
if [ -f "Dockerfile.kylinv10" ]; then
    echo "Using Dockerfile.kylinv10"
    DOCKERFILE="Dockerfile.kylinv10"
else
    cd ..
fi


# docker pull --platform linux/arm64 ubuntu:20.04
# DOCKER_BUILDKIT=1 BUILDX_NO_DEFAULT_ATTESTATIONS=1
# --provenance=false
# DOCKER_BUILDKIT=0 BUILDX_NO_DEFAULT_ATTESTATIONS=1 
docker  build --rm=false --platform linux/arm64 -t ccsafeenv-linux-builder:kylinv10 -f Dockerfile.kylinv10   .

# 运行如下命令启动容器
# docker run -it --platform linux/arm64  ccsafeenv-linux-builder:kylinv10 /bin/bash
# mkdir -p .root_claude && docker run -it -v ~/.claude/settings.json:/home/app/.claude/settings.json -v ~/.claude.json:/home/app/.claude.json -v $(pwd):/app1 -v $(pwd)/.root_claude:/home/app/.claude  ccsafeenv-linux-builder /bin/bash

# 运行如下命令启动claude
# claude --dangerously-skip-permissions
