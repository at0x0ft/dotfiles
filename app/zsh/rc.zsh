readonly ZSHRC_PATH=`cd $(dirname $(readlink $HOME/.zshrc)) && pwd`
source $ZSHRC_PATH/keybinds.zsh
source $ZSHRC_PATH/../brew/rc.sh
source $ZSHRC_PATH/zinit/rc.zsh
