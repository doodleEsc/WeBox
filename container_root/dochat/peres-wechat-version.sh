#!/usr/bin/env bash
set -eo pipefail

#
# Generate WeChat Version file by `peres` tool
#
#   Product Version:                 3.3.0.115
#     -> 3.3.0.115
#
WECHAT_DIR='/root/.wine/drive_c/Program Files (x86)/Tencent/WeChat/[3.6.0.18]'

peres -v "$WECHAT_DIR"/WeChatWin.dll | grep 'File Version: ' | awk '{print $3}' > /root/VERSION.WeChat
echo 'WeChat VERSION generated:'
cat /root/VERSION.WeChat
