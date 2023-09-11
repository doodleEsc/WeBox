#!/usr/bin/env bash
set -eo pipefail

bash -x /root/bin/dochat/install-wechat.sh
bash -x /root/bin/dochat/peres-wechat-version.sh
# bash -x /root/bin/dochat/regedit.sh
# bash -x /root/bin/dochat/disable-upgrade.sh
