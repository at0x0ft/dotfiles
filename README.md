# dotfiles

My preferences.

# How to install

## Linux (currently, only supporting ubuntu)

**After installing your preferred apps**, exec following command.

```sh
git clone https://github.com/at0x0ft/dotfiles.git ${HOME}/.dotfiles
${HOME}/.dotfiles/src/bin/install.sh
```

Note: If you want to know how to install apps, please refer to Dockerfiles in [`test` directory](./test) .

# How to redeploy

```sh
${HOME}/.dotfiles/src/bin/redeploy.sh
```
