FROM debian:bookworm

RUN <<EOR
apt-get update
echo "code code/add-microsoft-repo boolean true" | debconf-set-selections
apt-get install -y wget gpg
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
install -D -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft.gpg
rm -f microsoft.gpg
cat <<EOF > /etc/apt/sources.list.d/vscode.sources
Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64,arm64,armhf
Signed-By: /usr/share/keyrings/microsoft.gpg
EOF
apt-get install -y apt-transport-https
apt-get update
apt-get install -y code
apt-get clean
EOR

RUN <<EOR
apt-get update
apt-get install -y sudo
apt-get clean
EOR

RUN <<EOR
useradd -G sudo -m -s /bin/bash code
sed 's/^\%sudo/\%sudo   ALL=(ALL:ALL) NOPASSWD:ALL/g' -i /etc/sudoers
EOR

USER code
WORKDIR /home/code

CMD ["code", "serve-web", "--without-connection-token", "--accept-server-license-terms", "--host", "0.0.0.0", "--port", "80"]
