# CC-SafeEnv

> 基于 UOS (UnionTech OS) 的 Rust + Node.js 开发环境 Docker 镜像

一个高度优化的 Linux 开发环境镜像，专为 Rust 和 Node.js 项目设计，支持静态链接编译和 Claude Code AI 辅助开发。

## 📋 目录

- [特性](#-特性)
- [快速开始](#-快速开始)
- [镜像信息](#-镜像信息)
- [使用方法](#-使用方法)
- [开发环境](#-开发环境)
- [构建说明](#-构建说明)
- [优化历程](#-优化历程)
- [常见问题](#-常见问题)
- [许可证](#-许可证)

## ✨ 特性

### 🦀 Rust 开发环境
- **Rust 工具链**: 最新稳定版 (minimal profile)
- **交叉编译支持**: 
  - `x86_64-unknown-linux-musl` (静态链接)
  - `x86_64-unknown-linux-gnu` (动态链接)
- **OpenSSL 3.0.9**: 静态编译版本，支持 musl target

### 📦 Node.js 开发环境
- **Node.js 22**: 通过 nvm 管理
- **Claude Code**: AI 辅助编程工具
- **npm**: 最新版本

### 🎨 GUI 开发支持
完整的 GTK3 静态库编译环境：
- GTK+ 3.24.0
- Cairo 1.16.0
- Pango 1.50.14
- HarfBuzz 2.9.1
- ATK 2.38.0
- gdk-pixbuf 2.42.10

### 🔧 开发工具
- GCC/Clang 编译器
- musl-gcc (静态链接)
- Python 3 + pip
- Meson + Ninja 构建系统
- Git, wget, curl 等常用工具

## 🚀 快速开始

### 1. 构建镜像

```bash
# 使用构建脚本（推荐）
./scripts/build-uos.sh

# 或手动构建
docker build -f Dockerfile.uos -t ccsafeenv-linux-builder .
```

### 2. 运行容器

```bash
# 基本运行
docker run -it \
  -v $(pwd):/app1 \
  ccsafeenv-linux-builder \
  /bin/bash

# 使用 Claude Code（需要配置）
docker run -it \
  -v ~/.claude/settings.json:/home/app/.claude/settings.json \
  -v ~/.claude.json:/home/app/.claude.json \
  -v $(pwd):/app1 \
  -v $(pwd)/.root_claude:/home/app/.claude \
  ccsafeenv-linux-builder \
  /bin/bash
```

### 3. 在容器内开发

```bash
# 编译 Rust 项目（musl 静态链接）
cargo build --release --target x86_64-unknown-linux-musl

# 编译 Rust 项目（gnu 动态链接）
cargo build --release --target x86_64-unknown-linux-gnu

# 使用 Node.js
source ~/.nvm/nvm.sh
node --version
npm --version

# 使用 Claude Code
claude --dangerously-skip-permissions
```

## 📊 镜像信息

### 镜像大小

| 版本 | 大小 | 说明 |
|------|------|------|
| 初始版本 | 11.2GB | 未优化 |
| 优化版本 | **6.54GB** | 减少 41.6% ⭐ |

### 基础镜像
- **Base**: `macrosan/uos:v20-1070`
- **OS**: UnionTech OS v20
- **架构**: x86_64

### 用户配置
- **用户**: `app` (UID: 1000, GID: 1000)
- **主目录**: `/home/app`
- **工作目录**: `/app1`
- **数据目录**: `/data`

## 💻 使用方法

### Rust 项目开发

#### 静态链接编译（推荐用于分发）

```bash
# 设置环境变量
export OPENSSL_DIR=/usr/local/musl
export OPENSSL_STATIC=1

# 编译
cargo build --release --target x86_64-unknown-linux-musl

# 生成的二进制文件完全静态链接，无外部依赖
ldd target/x86_64-unknown-linux-musl/release/your-app
# 输出: not a dynamic executable
```

#### 动态链接编译

```bash
cargo build --release --target x86_64-unknown-linux-gnu
```

#### GTK 应用开发

```bash
# 静态链接 GTK 应用
PKG_CONFIG_PATH=/usr/local/lib/pkgconfig \
cargo build --release --target x86_64-unknown-linux-musl
```

### Node.js 项目开发

```bash
# 激活 nvm
source ~/.nvm/nvm.sh

# 安装依赖
npm install

# 运行项目
npm start

# 使用其他 Node.js 版本
nvm install 20
nvm use 20
```

### Claude Code AI 辅助

```bash
# 启动 Claude Code，因为是在容器中运行，所以应该相对安全！！！
claude --dangerously-skip-permissions

# 在项目目录中使用
cd /app1
claude
```

## 🔨 构建说明

### 构建选项

```bash
# 标准构建
docker build -f Dockerfile.uos -t ccsafeenv-linux-builder .

# 使用 BuildKit（推荐，更快）
DOCKER_BUILDKIT=1 docker build -f Dockerfile.uos -t ccsafeenv-linux-builder .

# 不使用缓存重新构建
docker build --no-cache -f Dockerfile.uos -t ccsafeenv-linux-builder .
```

### 构建时间

- **首次构建**: 约 30-60 分钟（取决于网络和 CPU）
- **增量构建**: 约 5-10 分钟（利用缓存）

### 构建要求

- **磁盘空间**: 至少 15GB 可用空间
- **内存**: 建议 4GB 以上
- **网络**: 需要下载约 2-3GB 的源码和依赖

## 📈 优化历程

本镜像经过两轮深度优化，从 11.2GB 降至 6.54GB：

### 第一轮优化（11.2GB → 8.24GB）
- ✅ 合并 RUN 命令减少镜像层
- ✅ 及时清理临时文件和源码
- ✅ 清理包管理器缓存
- ✅ 使用并行编译加速构建

### 第二轮优化（8.24GB → 6.54GB）
- ✅ Rust minimal profile（节省 ~550MB）
- ✅ 深度清理 Node.js 和 npm 缓存（节省 ~850MB）
- ✅ Strip 静态库 debug 符号（节省 ~100MB）
- ✅ 删除文档和非英文 locale（节省 ~150MB）
- ✅ 禁用共享库编译（节省 ~50MB）

**总优化效果**: 减少 4.66GB (41.6%) 🎉

详细优化说明请参考项目历史记录。

## 🔧 环境变量

容器内预设的环境变量：

```bash
HOME=/home/app
PATH=/home/app/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Rust 相关
CARGO_HOME=/home/app/.cargo
RUSTUP_HOME=/home/app/.rustup

# OpenSSL（用于 musl 静态链接）
OPENSSL_DIR=/usr/local/musl
OPENSSL_STATIC=1
```

## 📝 常见问题

### Q: 为什么选择 UOS 作为基础镜像？
A: UOS (UnionTech OS) 是基于 Debian 的中国本土化 Linux 发行版，提供了良好的中文支持和稳定性。

### Q: 如何在容器内访问宿主机的文件？
A: 使用 `-v` 参数挂载目录：
```bash
docker run -it -v /path/on/host:/path/in/container ccsafeenv-linux-builder /bin/bash
```

### Q: 编译的二进制文件可以在其他 Linux 发行版运行吗？
A: 使用 `x86_64-unknown-linux-musl` target 编译的二进制文件是完全静态链接的，可以在任何 x86_64 Linux 系统上运行，无需安装依赖。

### Q: 如何更新 Rust 版本？
A: 在容器内运行：
```bash
rustup update
```

### Q: 镜像太大，如何进一步优化？
A: 可以考虑：
1. 使用多阶段构建分离编译和运行环境
2. 只安装必需的开发工具，而不是整个 "Development Tools" 组
3. 根据实际需求删除不需要的静态库

### Q: 如何调试构建失败？
A: 
```bash
# 查看构建日志
docker build -f Dockerfile.uos -t ccsafeenv-linux-builder . 2>&1 | tee build.log

# 从失败的层启动容器调试
docker run -it <layer-id> /bin/bash
```

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

本项目采用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

## 🔗 相关链接

- [Rust 官方文档](https://www.rust-lang.org/)
- [Node.js 官方文档](https://nodejs.org/)
- [Claude Code](https://www.anthropic.com/)
- [UnionTech OS](https://www.uniontech.com/)
- [GTK Documentation](https://www.gtk.org/)

---

**Made with ❤️ for Rust and Node.js developers**

