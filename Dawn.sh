#!/bin/bash

# 脚本保存路径
SCRIPT_PATH="$HOME/Dawn.sh"
DAWN_DIR="$HOME/Dawn"
ZIP_URL="https://raw.githubusercontent.com/sky960718/DAWN/refs/heads/main/draw_.zip"
ZIP_FILE="$DAWN_DIR/draw_.zip"

# 检查是否以 root 用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以 root 用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到 root 用户，然后再次运行此脚本。"
    exit 1
fi

echo "正在检查 Docker 是否安装..."
if ! command -v docker &> /dev/null; then
	echo "Docker未安装，正在安装Docker..."

	# 更新系统
	sudo apt update -y && sudo apt upgrade -y

	# 移除可能存在的Docker相关包
	for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
		sudo apt-get remove -y $pkg
	done

	# 安装必要的依赖
	sudo apt-get update
	sudo apt-get install -y ca-certificates curl gnupg

	# 添加Docker的GPG密钥
	sudo install -m 0755 -d /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
	sudo chmod a+r /etc/apt/keyrings/docker.gpg

	# 添加Docker的APT源
	echo \
	  "deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
	  \"$(. /etc/os-release && echo "$VERSION_CODENAME")\" stable" | \
	  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

	# 更新APT源并安装Docker
	sudo apt update -y && sudo apt upgrade -y
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

	# 确保docker-compose可执行
	sudo chmod +x /usr/local/bin/docker-compose

	# 检查Docker版本
	echo "Docker安装完成，版本为：$(docker --version)"
else
	echo "Docker已安装，版本为：$(docker --version)"
fi

# 创建Dawn目录（如果不存在）
mkdir -p $DAWN_DIR
cd $DAWN_DIR

# 下载压缩包
echo "正在下载压缩包..."
curl -L -o $ZIP_FILE $ZIP_URL

# 解压压缩包
echo "正在解压压缩包..."
unzip -o $ZIP_FILE -d $DAWN_DIR

# 删除压缩包
echo "删除压缩包..."
rm $ZIP_FILE

# 启动Docker服务
echo "启动Docker服务..."
docker-compose up -d

echo "脚本执行完成。"
