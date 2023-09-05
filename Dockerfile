FROM webox-wine:0.1

ENV VNCPASS=YourSafeVNCPassword
ENV LANG=zh_CN.UTF-8
ENV LC_ALL=zh_CN.UTF-8
ENV DISPLAY=:5

RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        locales \
        wget \
        mesa-utils \
        procps \
        pev \
        vim \
        sudo \
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
    && echo "LC_ALL=zh_CN.UTF-8" >> /etc/default/locale

RUN wget --no-check-certificate -O /bin/dumb-init "https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_x86_64" \
    && chmod a+x /bin/dumb-init

COPY [A-Z]* /root/
COPY VERSION /root/VERSION.docker-wechat
COPY container_root/ /root/bin/
COPY data/wechat_3.6.0.18.tar.gz /root/
COPY data/DaenWxHook.dll /root/bin/
COPY data/inject.exe     /root/bin/

# setup wechat
RUN mkdir -p "/root/WeChat Files" "/root/.wine/drive_c/users/user/Application Data" \
    && bash -x /root/bin/setup.sh

VOLUME [\
  "/root/WeChat Files", \
  "/root/.wine/drive_c/users/user/Application Data" \
]

COPY run.py /root/
ENTRYPOINT [ "/bin/dumb-init" ]
CMD ["/usr/bin/python3", "/root/run.py"]
