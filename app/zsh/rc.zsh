local ZSHRC_PATH=`dirname $(readlink -f $HOME/.zshrc)`
source $ZSHRC_PATH/keybinds.zsh
source $ZSHRC_PATH/../brew/rc.sh
source $ZSHRC_PATH/zinit/rc.zsh
unset ZSHRC_PATH
