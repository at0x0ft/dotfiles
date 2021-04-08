# syntax = docker/dockerfile:1.2
ARG VERSION
FROM debian:${VERSION}

ARG USER_NAME=testuser
ARG USER_PASSWORD=testuser
ARG DOTFILES_PATH
ARG USER_HOMEDIR=/home/${USER_NAME}
ARG DOTFILES_DST=${USER_HOMEDIR}/.dotfiles
ARG TERM

RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates \
    libncurses-dev \
    unzip \
    curl \
    file \
    jq \
    zsh \
    git \
    gcc \
    make \
    # autoconf \
 && useradd -s $(which zsh) -m -G sudo ${USER_NAME} \
 && echo "${USER_NAME}:${USER_PASSWORD}" | chpasswd

USER ${USER_NAME}
WORKDIR ${USER_HOMEDIR}

RUN command mkdir -p "${USER_HOMEDIR}/.zinit" && command chmod g-rwX "${USER_HOMEDIR}/.zinit" \
 && command git clone https://github.com/zdharma/zinit "${USER_HOMEDIR}/.zinit/bin"

COPY --chown=${USER_NAME}:${USER_NAME} ${DOTFILES_PATH} ${DOTFILES_DST}
ENV TERM ${TERM}
RUN ${DOTFILES_DST}/src/bin/install.sh

CMD [ "su", "-", "testuser" ]
