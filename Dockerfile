FROM wine:0.1

ENV VNCPASS=YourSafeVNCPassword
ENV LANG=zh_CN.UTF-8
ENV LC_ALL=zh_CN.UTF-8
ENV DISPLAY=:5
ENV CALLBACK=callBackUrl=http://127.0.0.1:9528/wxbot/callback\&port=9527\&decryptImg=1

WORKDIR /root/app

RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        locales \
        wget \
        procps \
        pev \
        tigervnc-standalone-server \
        tigervnc-common \
        openbox \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -fr /tmp/*


ARG root_password
RUN echo "root:${root_password}" | chpasswd \
    && localedef -i zh_CN -c -f UTF-8 zh_CN.UTF-8 \
    && echo "LANG=zh_CN.UTF-8" >> /etc/default/locale \
    && echo "LC_ALL=zh_CN.UTF-8" >> /etc/default/locale \
    && wget --no-check-certificate -O /bin/dumb-init "https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_x86_64" \
    && chmod a+x /bin/dumb-init

COPY VERSION /root/VERSION
COPY container_root/ /root/bin/
COPY data/wechat_3.6.0.18.tar.gz /root/
COPY data/Hook /root/Hook
COPY run.py /root/

RUN bash -x /root/bin/setup.sh \
    && rm -f /root/Hook.tar.gz \
    && rm -f /root/wechat_3.6.0.18.tar.gz \
    && rm -rf "/root/.wine/drive_c/users/root/AppData/Roaming/Tencent/WeChat/xweb/crash/Crashpad/reports" \
    && mkdir -p "/root/.wine/drive_c/users/root/AppData/Roaming/Tencent/WeChat/xweb/crash/Crashpad" \
    && touch "/root/.wine/drive_c/users/root/AppData/Roaming/Tencent/WeChat/xweb/crash/Crashpad/reports"

ENTRYPOINT [ "/bin/dumb-init" ]
CMD ["/usr/bin/python3", "/root/run.py"]
