# syntax = docker/dockerfile:1.2
ARG VERSION
FROM homebrew/ubuntu${VERSION}:latest

ARG USER_NAME=testuser
ARG USER_PASSWORD=testuser
ARG DOTFILES_PATH
ARG USER_HOMEDIR=/home/${USER_NAME}
ARG DOTFILES_DST=${USER_HOMEDIR}/.dotfiles

RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    libncurses-dev \
 && useradd -s /bin/bash -m -G sudo ${USER_NAME} \
 && echo "${USER_NAME}:${USER_PASSWORD}" | chpasswd \
 && chown -R ${USER_NAME} /home/linuxbrew/.linuxbrew

USER ${USER_NAME}
WORKDIR ${USER_HOMEDIR}

RUN mkdir ${USER_HOMEDIR}/.cache ${USER_HOMEDIR}/.cache/Homebrew
RUN --mount=type=cache,target=/home/testuser/.cache/Homebrew \
    if [ -d ${USER_HOMEDIR}/.linuxbrew ]; then eval $(${USER_HOMEDIR}/.linuxbrew/bin/brew shellenv); \
    elif [ -d /home/linuxbrew/.linuxbrew ]; then eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv); fi \
 && brew install \
    gcc \
    git \
    zsh \
    subversion \
    autoconf \
    vim \
 && echo ${USER_PASSWORD} | sudo -S sh -c "echo $(which zsh) >> /etc/shells" \
 && echo ${USER_PASSWORD} | sudo -S chsh ${USER_NAME} -s $(which zsh) \
 && command mkdir -p "${USER_HOMEDIR}/.zinit" && command chmod g-rwX "${USER_HOMEDIR}/.zinit" \
 && command git clone https://github.com/zdharma/zinit "${USER_HOMEDIR}/.zinit/bin"

COPY --chown=${USER_NAME}:${USER_NAME} ${DOTFILES_PATH} ${DOTFILES_DST}
RUN ${DOTFILES_DST}/src/bin/install.sh

CMD [ "su", "-", "testuser" ]
