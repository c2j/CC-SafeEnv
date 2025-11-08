#!/bin/bash
# Build script for Linux targets using vcpkg with fallback support

# 如果当前目录下有Dockerfile.nos，则使用Dockerfile.nos
if [ -f "Dockerfile.uos" ]; then
    echo "Using Dockerfile.uos"
    DOCKERFILE="Dockerfile.uos"
else
    cd ..
fi  



docker build -t ccsafeenv-linux-builder -f Dockerfile.uos .

# 运行如下命令启动容器
# docker run -it -v ~/.claude/settings.json:/home/app/.claude/settings.json -v ~/.claude.json:/home/app/.claude.json -v $(pwd):/app1 -v $(pwd)/.root_claude:/home/app/.claude ccsafeenv-linux-builder /bin/bash

# 运行如下命令启动claude
# claude --dangerously-skip-permissions
