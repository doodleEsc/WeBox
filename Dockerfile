FROM ubuntu:22.04

SHELL ["/bin/bash", "-c"]

# Install prerequisites
RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        cabextract \
        git \
        gnupg \
        gosu \
        gpg-agent \
        locales \
        p7zip \
        tzdata \
        unzip \
        wget \
        ttf-wqy-microhei \
        ttf-wqy-zenhei \
        xfonts-wqy \
        curl \
        software-properties-common \
        mesa-utils \
        procps \
        pev \
        sudo \
        vim \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -fr /tmp/*

        # pulseaudio \
        # pulseaudio-utils \
        # zenity \
        # winbind \
        # xvfb \

# Configure locale for unicode
RUN locale-gen zh_CN.UTF-8
ENV \
  LANG='zh_CN.UTF-8' \
  LC_ALL='zh_CN.UTF-8' \
  TZ=Asia/Shanghai \
  WINEDEBUG=-all

RUN groupadd group \
  && useradd -m -g group user \
  && usermod -a -G audio user \
  && usermod -a -G video user \
  && chsh -s /bin/bash user \
  && echo 'User Created'

# Install wine
RUN dpkg --add-architecture i386 \
  && mkdir -pm755 /etc/apt/keyrings \
  && wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key \
  # && wget -nv -O- https://dl.winehq.org/wine-builds/winehq.key | APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key add - \
  && wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources \
  && apt-get update \
  && DEBIAN_FRONTEND="noninteractive" apt-get install -y --install-recommends winehq-stable \
  && echo 'i386 Architecture & Wine Repo Added' \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -fr /tmp/*

# Download gecko and mono installers
COPY download_gecko_and_mono.sh /root/download_gecko_and_mono.sh
RUN chmod +x /root/download_gecko_and_mono.sh \
    && /root/download_gecko_and_mono.sh "$(wine --version | sed -E 's/^wine-//')" \
    && echo "Gecko and Mono Installed"

# Install winetricks
RUN wget -nv -O /usr/bin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
    && chmod +x /usr/bin/winetricks \
    && echo "Winetricks Installed" \
    \
# wintricks
    && su user -c 'winetricks -q msls31' \
    && su user -c 'winetricks -q ole32' \
    && su user -c 'winetricks -q riched20' \
    && su user -c 'winetricks -q riched30' \
    && su user -c 'winetricks -q win7' \
    \
# Clean
    && rm -fr /usr/share/wine/{gecko,mono} \
    && rm -fr /home/user/{.cache,tmp}/* \
    && rm -fr /tmp/* \
    && echo 'Wine Initialized'

# install wechat
COPY --chown=user:group container_root/ /
COPY [A-Z]* /
COPY VERSION /VERSION.docker-wechat

RUN chown user /home \
  && localedef -i zh_CN -c -f UTF-8 zh_CN.UTF-8 \
  && echo 'user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
  && echo '127.0.0.1 dldir1.qq.com' >> /etc/hosts

USER user
# RUN bash -x /setup.sh
# ENTRYPOINT [ "/entrypoint.sh" ]
