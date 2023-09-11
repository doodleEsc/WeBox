#!/usr/bin/env bash
set -eo pipefail

tmpRegFile=$(mktemp /tmp/regedit.XXXXXXXXX.reg)
trap 'rm -f "$tmpRegFile"' EXIT

cat <<_EOF_ > "$tmpRegFile"
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\Tencent\WeChat]
"ChannelId"=dword:000003e8
"Version"=dword:63060012
"LANG_ID"=dword:00000004
"CrashVersion"=dword:63060012
"CrashCnt"=dword:00000000
"FileSavePath"="MyDocument:"
"NeedUpdateType"=dword:00000000
_EOF_

#
# Setup WeChat in Windows Registry
#
wine regedit.exe /s "$tmpRegFile"
wine reg add 'HKEY_CURRENT_USER\Software\Tencent\WeChat' /v InstallPath /t reg_sz /d "C:\\Program Files (x86)\\Tencent\\WeChat"
wine reg query 'HKEY_CURRENT_USER\Software\Tencent\WeChat'
echo 'Regedit Initialized'
# FIXME: reg set success or not ???
wine reg query 'HKEY_CURRENT_USER\Software\Tencent\WeChat' || echo 'Graceful FAIL. REG NOT FOUND'
