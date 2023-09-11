#!/usr/bin/env bash
set -eo pipefail

cd /root
tar zxf /root/wechat_3.6.0.18.tar.gz
mv Hook '/root/.wine/drive_c/Program Files (x86)/'
cd /root/bin
echo 'Artifacts Downloaded'
