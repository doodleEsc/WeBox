#!/usr/bin/python3

import subprocess
import os
import signal
import datetime
import time


class DockerWechatHook:
    def __init__(self):
        signal.signal(signal.SIGINT, self.now_exit)
        signal.signal(signal.SIGHUP, self.now_exit)
        signal.signal(signal.SIGTERM, self.now_exit)

    def now_exit(self, signum, frame):
        self.exit_container()

    def run_vnc(self):
        # 根据VNCPASS环境变量生成vncpasswd文件
        os.makedirs("/root/.vnc", mode=755, exist_ok=True)
        passwd_output = subprocess.run(
            ["/usr/bin/vncpasswd", "-f"],
            input=os.environ["VNCPASS"].encode(),
            capture_output=True,
        )

        with open("/root/.vnc/passwd", "wb") as f:
            f.write(passwd_output.stdout)
        os.chmod("/root/.vnc/passwd", 0o700)
        self.vnc = subprocess.Popen(
            [
                "/usr/bin/vncserver",
                "-localhost",
                "no",
                "-xstartup",
                "/usr/bin/openbox",
                ":5",
            ]
        )

    def set_reg(self):
        subprocess.Popen(["bash", "/root/bin/dochat/regedit.sh"])

    def set_disable_upgrade(self):
        subprocess.Popen(["bash", "/root/bin/dochat/disable-upgrade.sh"])

    def set_hosts(self):
        try:
            with open("/etc/hosts", "a") as file:
                file.write("127.0.0.1 dldir1.qq.com\n")
        except Exception as e:
            print(f"Error occurred: {e}")

    def run_hook(self):
        callback = os.environ.get(
            "CALLBACK", "callBackUrl=http://127.0.0.1:9528/wxbot/callback&port=9527&decryptImg=1")

        self.hook = subprocess.Popen(
            [
                "wine",
                "/root/.wine/drive_c/Program Files (x86)/Hook/inject.exe",
                "C:\Program Files (x86)\Tencent\WeChat\[3.6.0.18]",
                "C:\Program Files (x86)\Hook\DaenWxHook.dll",
                callback
            ],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.STDOUT
        )

    def run_bot(self):
        self.bot = subprocess.run(["/root/app/wxbot"], cwd="/root/app")

    def exit_container(self):
        print(datetime.datetime.now().strftime(
            "%Y-%m-%d %H:%M:%S") + " 正在退出容器...")

        try:
            print(
                datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S") + " 退出Hook程序..."
            )
            os.kill(self.hook.pid, signal.SIGTERM)
        except Exception:
            pass

        try:
            print(datetime.datetime.now().strftime(
                "%Y-%m-%d %H:%M:%S") + " 退出VNC...")

            os.kill(self.vnc.pid, signal.SIGTERM)

        except Exception as e:
            raise e

        print(datetime.datetime.now().strftime(
            "%Y-%m-%d %H:%M:%S") + " 已退出容器.")

    def run_all_in_one(self):
        print(datetime.datetime.now().strftime(
            "%Y-%m-%d %H:%M:%S") + " 启动容器中...")
        self.set_hosts()
        self.set_reg()
        self.run_vnc()
        self.run_hook()
        time.sleep(5)
        self.set_disable_upgrade()
        self.run_bot()
        print(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S") + " 启动完成.")


if __name__ == "__main__":
    print("---All in one 微信Hook容器---")

    hook = DockerWechatHook()

    hook.run_all_in_one()
