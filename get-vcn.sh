#!/bin/bash

if [[ $# -gt  0 ]]; then
    echo "Obtained version input: $1 from workflow; The action will use this instead of looking \
     for the latest available release. If this is a mistake, please remove the 'version' section from this action\
     and restart your workflow to use latest available release"
    version_string=$1
    base_url="https://github.com/vchain-us/vcn/releases/download/$version_string"
fi

if [[ -z "${version_string}" ]]; then
    version_string=$(curl -s https://api.github.com/repos/codenotary/vcn/releases/latest | awk '/tag_name/ {gsub(/"/,""); gsub(/,/,""); print $2}')
    base_url=https://github.com/codenotary/vcn/releases/latest/download
    echo "Latest available release for VCN is: $version_string"
fi
linux_file="$base_url/vcn-$version_string-linux-amd64-static"
windows_file="$base_url/vcn-$version_string-windows-amd64.exe"
mac_file="$base_url/vcn-$version_string-darwin-amd64"
os_name=$(uname -s)
out=""

case "${os_name}" in
    Linux*)     target=$linux_file;;
    Darwin*)    target=$mac_file;;
    CYGWIN*)    target="$windows_file" && out=".exe";;
    MINGW*)     target="$windows_file" && out=".exe";;
    *)          echo "Unsupported runner OS, aborting VCN Download" && exit 1;;
esac

curl -s -L "$target" -o vcn"$out" && chmod +x vcn*
echo "Succesfully acquired VCN binary"
