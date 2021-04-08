# Dotfiles Testing Dockerfiles

Dockerfiles for testing environment.

# How to test

```sh
./build.sh <path to Dockerfile from this directory> <distro version> [ -c : build environment flag (container or not) ]
```

For example...

```sh
# Build & test dotfiles in Ubuntu 20.04 desktop
./build.sh ubuntu 20.04
# Build & test dotfiles in Debian latest container
./build.sh debian latest -c
```
