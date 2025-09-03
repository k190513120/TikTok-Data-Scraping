# 使用官方 Python 3.12 镜像（包含编译工具）
FROM python:3.12

LABEL maintainer="Evil0ctal"

# 设置非交互模式，避免 Docker 构建时的交互问题
ENV DEBIAN_FRONTEND=noninteractive

# 设置PyO3兼容性环境变量
ENV PYO3_USE_ABI3_FORWARD_COMPATIBILITY=1

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /app

# 先复制依赖文件，利用Docker缓存
COPY requirements.txt .

# 升级pip并安装依赖
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# 复制应用代码到容器
COPY . .

# 确保启动脚本可执行
RUN chmod +x start.sh

# 创建非root用户
RUN useradd --create-home --shell /bin/bash app \
    && chown -R app:app /app
USER app

# 暴露端口
EXPOSE 8000

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:${PORT:-8000}/docs || exit 1

# 设置容器启动命令
CMD ["python3", "start.py"]
