#!/bin/bash

# 安装 yum-utils
sudo yum install -y yum-utils

# 添加 Docker CE 的 yum 仓库
sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

# 列出可用的 Docker CE 版本
echo "以下是可用的 Docker CE 版本："
yum list docker-ce --showduplicates | sort -r

# 提示用户输入 Docker CE 版本
read -p "请输入你想要安装的 Docker CE 版本（例如：20.10.17）：" DOCKER_VERSION

# 安装用户选择的 Docker CE 和 Docker CE CLI 版本
sudo yum install -y docker-ce-$DOCKER_VERSION docker-ce-cli-$DOCKER_VERSION

# 启动 Docker 服务
sudo systemctl enable docker --now

# 创建 Docker 配置文件目录
sudo mkdir -p /etc/docker

# 创建 Docker 配置文件
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://5wdxuqv0.mirror.aliyuncs.com"],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

# 重新加载系统守护进程
sudo systemctl daemon-reload

# 重启 Docker 服务
sudo systemctl restart docker

# 添加 Kubernetes 的 yum 仓库
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
   http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

# 列出可用的 kubelet、kubeadm 和 kubectl 版本
echo "以下是可用的 kubelet、kubeadm 和 kubectl 版本："
yum list kubelet --showduplicates | sort -r
yum list kubeadm --showduplicates | sort -r
yum list kubectl --showduplicates | sort -r

# 提示用户输入 kubelet、kubeadm 和 kubectl 版本
read -p "请输入你想要安装的 kubelet、kubeadm 和 kubectl 版本（例如：1.21.10）：" KUBE_VERSION

# 安装用户选择的 kubelet、kubeadm 和 kubectl 版本
sudo yum install -y kubelet-$KUBE_VERSION kubeadm-$KUBE_VERSION kubectl-$KUBE_VERSION --disableexcludes=kubernetes

# 启动 kubelet 服务
sudo systemctl enable --now kubelet

# 拉取 Kubernetes 镜像
kubeadm config images pull --kubernetes-version $KUBE_VERSION --image-repository registry.cn-hangzhou.aliyuncs.com/google_containers
