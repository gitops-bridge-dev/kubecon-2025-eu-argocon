#!/usr/bin/env bash

# For Kubectl AMD64 / x86_64
[ $(uname -m) = x86_64 ] && curl -sLO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
# For Kubectl ARM64
[ $(uname -m) = aarch64 ] && curl -sLO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# For Kind AMD64 / x86_64
arch=$(if [[ "$(uname -m)" == "x86_64" ]]; then echo "amd64"; else echo "arm64"; fi)
os=$(uname -s | tr '[:upper:]' '[:lower:]')
kind_latest_tag=$(curl --silent "https://api.github.com/repos/kubernetes-sigs/kind/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
curl -sLo ./kind https://kind.sigs.k8s.io/dl/{$kind_latest_tag}/kind-${os}-${arch}
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
kind version

# For CNOE idpbuilder AMD64 / x86_64
nightly=yes
[ ${nightly} = yes ] && idpbuilder_latest_tag=$(curl -s "https://api.github.com/repos/cnoe-io/idpbuilder/releases" | jq -r 'sort_by(.created_at) | reverse | .[0].tag_name')
[ ${nightly} = no ]  && idpbuilder_latest_tag=$(curl --silent "https://api.github.com/repos/cnoe-io/idpbuilder/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
arch=$(if [[ "$(uname -m)" == "x86_64" ]]; then echo "amd64"; else echo "arm64"; fi)
os=$(uname -s | tr '[:upper:]' '[:lower:]')
curl -sLO https://github.com/cnoe-io/idpbuilder/releases/download/${idpbuilder_latest_tag}/idpbuilder-${os}-${arch}.tar.gz
tar -xvzf idpbuilder-${os}-${arch}.tar.gz -C /tmp
chmod +x /tmp/idpbuilder
sudo mv /tmp/idpbuilder /usr/local/bin/idpbuilder
idpbuilder version

# helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# vlcuster CLI
arch=$(if [[ "$(uname -m)" == "x86_64" ]]; then echo "amd64"; else echo "arm64"; fi)
os=$(uname -s | tr '[:upper:]' '[:lower:]')
vcluster_latest_tag=$(curl --silent "https://api.github.com/repos/loft-sh/vcluster/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
curl -s -L -o vcluster "https://github.com/loft-sh/vcluster/releases/download/${vcluster_latest_tag}/vcluster-${os}-${arch}"
sudo install -c -m 0755 vcluster /usr/local/bin
rm -f vcluster

# setup autocomplete for kubectl and alias k
sudo apt-get update -y && sudo apt-get install bash-completion -y
mkdir $HOME/.kube
echo "source <(kubectl completion bash)" >> $HOME/.bashrc
echo "alias k=kubectl" >> $HOME/.bashrc
echo "complete -F __start_kubectl k" >> $HOME/.bashrc
# if docker network kind is not exist, create it
if [ -z "$(docker network ls | grep kind)" ]; then
docker network create -d=bridge -o com.docker.network.bridge.enable_ip_masquerade=true -o com.docker.network.driver.mtu=1500 --subnet fc00:f853:ccd:e793::/64 kind
fi

# setup git secrets
tempdir="$(mktemp -d)"
git clone https://github.com/awslabs/git-secrets.git $tempdir
pushd $tempdir
sudo make install
popd

