# Add brew command for linux
if [[ -d $HOME/.linuxbrew ]]; then
    eval $($HOME/.linuxbrew/bin/brew shellenv)
fi

if [[ -d /home/linuxbrew/.linuxbrew ]]; then
    eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
fi
